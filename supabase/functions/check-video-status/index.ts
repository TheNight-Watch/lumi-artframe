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

    // Support both GET query params and POST body
    let taskId: string;
    if (req.method === "GET") {
      const url = new URL(req.url);
      taskId = url.searchParams.get("task_id") ?? "";
    } else {
      const body = await req.json();
      taskId = body.task_id ?? "";
    }

    if (!taskId) {
      return new Response(
        JSON.stringify({ code: "BAD_REQUEST", message: "task_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Call Seedance2 CVSync2AsyncGetResult
    const requestBody = JSON.stringify({
      req_key: "jimeng_i2v_first_v30",
      task_id: taskId,
    });

    const { url, headers } = await signVolcengineRequest(
      "CVSync2AsyncGetResult",
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
      // Task might still be processing
      if (volcData.data?.status === "running" || volcData.data?.status === "pending") {
        return new Response(
          JSON.stringify({ task_id: taskId, status: "processing" }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      throw new Error(`Seedance2 error: ${volcData.message || JSON.stringify(volcData)}`);
    }

    const status = volcData.data?.status;
    const videoUrl = volcData.data?.video_url ?? volcData.data?.resp_data?.video_url;

    if (status === "done" && videoUrl) {
      // Update artwork record
      const { error: updateError } = await supabase
        .from("artworks")
        .update({
          video_status: "completed",
          video_url: videoUrl,
        })
        .eq("video_task_id", taskId)
        .eq("user_id", user.id);

      if (updateError) {
        console.error("Failed to update artwork:", updateError);
      }

      return new Response(
        JSON.stringify({ task_id: taskId, status: "completed", video_url: videoUrl }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (status === "failed") {
      // Update artwork record
      await supabase
        .from("artworks")
        .update({ video_status: "failed" })
        .eq("video_task_id", taskId)
        .eq("user_id", user.id);

      return new Response(
        JSON.stringify({ task_id: taskId, status: "failed" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Still processing
    return new Response(
      JSON.stringify({ task_id: taskId, status: "processing" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ code: "INTERNAL_ERROR", message: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
