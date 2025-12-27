import { NextResponse } from 'next/server';
import Groq from 'groq-sdk';

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const text = searchParams.get('text');

  if (!text) return NextResponse.json({ error: "No text" }, { status: 400 });

  try {
    const completion = await groq.chat.completions.create({
      model: "llama-3.3-70b-versatile",
      messages: [
        { 
          role: "system", 
          content: "You are a real Roblox player. Use the context provided (Game, Appearance, and History) to talk naturally. Keep replies very short (1 sentence). Don't act like a bot." 
        },
        { role: "user", content: text }
      ],
      max_tokens: 80,
    });

    let reply = completion.choices[0]?.message?.content || "";
    
    // Clean up any AI artifacts
    reply = reply.replace(/["\n]/g, ""); 

    return NextResponse.json({ reply });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}