import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createSupabaseClient } from "../_shared/supabase-client.ts";
import { signVolcengineRequest } from "../_shared/volcengine-signer.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ code: "UNAUTHORIZED", message: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createSupabaseClient(authHeader);
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return new Response(
        JSON.stringify({ code: "UNAUTHORIZED", message: "Invalid token" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { image_url, prompt } = await req.json();

    if (!image_url || !prompt) {
      return new Response(
        JSON.stringify({ code: "BAD_REQUEST", message: "image_url and prompt are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Call Seedance2 CVSync2AsyncSubmitTask
    const requestBody = JSON.stringify({
      req_key: "jimeng_i2v_first_v30",
      image_urls: [image_url],
      prompt: prompt,
      seed: -1,
      frames: 121,
    });

    const { url, headers } = await signVolcengineRequest(
      "CVSync2AsyncSubmitTask",
      "2022-08-31",
      requestBody
    );

    const volcResponse = await fetch(url, {
      method: "POST",
      headers,
      body: requestBody,
    });

    const volcData = await volcResponse.json();

    if (volcData.code !== 10000) {
      throw new Error(`Seedance2 error: ${volcData.message || JSON.stringify(volcData)}`);
    }

    const taskId = volcData.data?.task_id;
    if (!taskId) {
      throw new Error("No task_id returned from Seedance2");
    }

    // Update artwork record with video task info
    const { error: updateError } = await supabase
      .from("artworks")
      .update({
        video_task_id: taskId,
        video_status: "processing",
      })
      .eq("image_url", image_url)
      .eq("user_id", user.id);

    if (updateError) {
      console.error("Failed to update artwork:", updateError);
    }

    return new Response(
      JSON.stringify({ task_id: taskId, status: "processing" }),
      { status: 202, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ code: "INTERNAL_ERROR", message: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
