import { NextResponse } from 'next/server';
import Groq from 'groq-sdk';

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export async function POST(request) {
  try {
    const body = await request.json();
    
    // All AI parameters are sent from the Roblox Script
    const { messages, model, temperature, max_tokens } = body;

    const completion = await groq.chat.completions.create({
      model: model || "llama-3.3-70b-versatile",
      messages: messages, // History managed by Roblox
      temperature: temperature || 0.7,
      max_tokens: max_tokens || 150,
    });

    const reply = completion.choices[0]?.message?.content || "";
    return NextResponse.json({ reply });
  } catch (error) {
    console.error("Groq Error:", error.message);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
