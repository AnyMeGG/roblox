export default function Page() { 
  return (
    <div style={{fontFamily: 'sans-serif', textAlign: 'center', marginTop: '100px'}}>
      <h1 style={{fontSize: '3rem'}}>🧠 Headless Groq Proxy</h1>
      <p style={{color: '#666'}}>Logic and Memory are currently controlled by the Roblox Lua Script.</p>
      <div style={{background: '#f4f4f4', padding: '20px', borderRadius: '10px', display: 'inline-block'}}>
        <code>Listening on: <strong>https://roblox-one-xi.vercel.app/api/chat</strong></code>
      </div>
    </div>
  )
}