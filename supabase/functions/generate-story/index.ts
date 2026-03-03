import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { createSupabaseClient } from "../_shared/supabase-client.ts";

const DEEPSEEK_API_KEY = Deno.env.get("DEEPSEEK_API_KEY") ?? "";
const DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions";

const SYSTEM_PROMPT = `You are a creative children's story writer and child psychologist.
Given an image of a child's drawing and optionally a voice transcript description, generate:
1. A fairy tale story inspired by the drawing (200-300 words, suitable for ages 3-12)
2. A psychological analysis of the child's creativity and emotional state

You MUST respond in valid JSON with exactly these fields:
{
  "story_title": "Story title (creative, engaging)",
  "story_content": "The full fairy tale story text",
  "video_prompt": "A detailed prompt for generating an animated video from this drawing (English, 50-100 words)",
  "creativity_analysis": "Analysis of the child's creative expression (100-150 words)",
  "mood_analysis": "Analysis of the child's emotional state based on the drawing (100-150 words)",
  "additional_insights": "Additional developmental or psychological insights (50-100 words)"
}`;

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

    const { image_url, audio_transcript } = await req.json();

    if (!image_url) {
      return new Response(
        JSON.stringify({ code: "BAD_REQUEST", message: "image_url is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build user message
    let userMessage = `Here is a child's drawing: ${image_url}`;
    if (audio_transcript) {
      userMessage += `\n\nThe child described the drawing as: "${audio_transcript}"`;
    }
    userMessage += "\n\nPlease generate a story and psychological analysis.";

    // Call Deepseek API
    const deepseekResponse = await fetch(DEEPSEEK_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${DEEPSEEK_API_KEY}`,
      },
      body: JSON.stringify({
        model: "deepseek-chat",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: userMessage },
        ],
        response_format: { type: "json_object" },
        temperature: 0.8,
        max_tokens: 2000,
      }),
    });

    if (!deepseekResponse.ok) {
      const errText = await deepseekResponse.text();
      throw new Error(`Deepseek API error: ${deepseekResponse.status} ${errText}`);
    }

    const deepseekData = await deepseekResponse.json();
    const content = deepseekData.choices?.[0]?.message?.content;

    if (!content) {
      throw new Error("Empty response from Deepseek");
    }

    const storyData = JSON.parse(content);

    // Update artwork record with story data
    const { error: updateError } = await supabase
      .from("artworks")
      .update({
        story_title: storyData.story_title,
        story_content: storyData.story_content,
        video_prompt: storyData.video_prompt,
        creativity_analysis: storyData.creativity_analysis,
        mood_analysis: storyData.mood_analysis,
        additional_insights: storyData.additional_insights,
        title: storyData.story_title,
      })
      .eq("image_url", image_url)
      .eq("user_id", user.id);

    if (updateError) {
      console.error("Failed to update artwork:", updateError);
    }

    return new Response(
      JSON.stringify({
        id: crypto.randomUUID(),
        ...storyData,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ code: "INTERNAL_ERROR", message: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
