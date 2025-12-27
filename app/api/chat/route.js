import { NextResponse } from 'next/server';
import Groq from 'groq-sdk';

const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

if (!global.chatHistory) {
  global.chatHistory = [];
}

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const text = searchParams.get('text');

  if (!text) return NextResponse.json({ error: "No text" }, { status: 400 });

  global.chatHistory.push({ role: "user", content: text });

  try {
    const completion = await groq.chat.completions.create({
      // Using Llama 3.3 70B for high quality and speed
      model: "llama-3.3-70b-versatile",
      messages: global.chatHistory,
      max_tokens: 150,
    });

    const reply = completion.choices[0]?.message?.content || "";
    global.chatHistory.push({ role: "assistant", content: reply });

    // Keep memory to last 12 messages
    if (global.chatHistory.length > 12) global.chatHistory.splice(0, 2);

    console.log(`User: ${text}\nGroq: ${reply}\n---`);
    return NextResponse.json({ reply });
  } catch (error) {
    console.error("Groq Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
