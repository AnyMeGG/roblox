import { NextResponse } from 'next/server';

export async function GET() {
  global.chatHistory = [];
  console.log("History cleared.");
  return NextResponse.json({ status: "cleared" });
}
