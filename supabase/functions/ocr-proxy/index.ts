const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const formData = await req.formData();
    const file = formData.get("file") as File;
    const language = (formData.get("language") as string) || "ita";

    if (!file) {
      return new Response(JSON.stringify({ error: "File mancante" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (file.size > 10 * 1024 * 1024) {
      return new Response(JSON.stringify({ error: "File troppo grande (max 10MB)" }), {
        status: 413,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const ocrKey = Deno.env.get("OCR_API_KEY");
    if (!ocrKey) {
      console.error("[ocr-proxy] OCR_API_KEY non impostata");
      return new Response(JSON.stringify({ error: "Configurazione mancante: OCR_API_KEY non impostata" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const fd = new FormData();
    fd.append("file", file);
    fd.append("apikey", ocrKey);
    fd.append("language", language);
    fd.append("isOverlayRequired", "false");
    fd.append("scale", "true");
    fd.append("OCREngine", "2");

    console.log("[ocr-proxy] Invio richiesta a OCR.space, file size:", file.size);

    const ocrResp = await fetch("https://api.ocr.space/parse/image", {
      method: "POST",
      body: fd,
    });

    if (!ocrResp.ok) {
      const errBody = await ocrResp.text();
      console.error("[ocr-proxy] OCR API error:", ocrResp.status, errBody);
      return new Response(JSON.stringify({ error: `Errore OCR API (${ocrResp.status})`, details: errBody }), {
        status: ocrResp.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const result = await ocrResp.json();
    console.log("[ocr-proxy] OCR completato, IsErroredOnProcessing:", result?.IsErroredOnProcessing);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("[ocr-proxy] Unexpected error:", e);
    return new Response(JSON.stringify({ error: "Errore interno: " + String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
