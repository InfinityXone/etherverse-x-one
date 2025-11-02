import { ImageResponse } from "next/og";
export const runtime = "edge";
export const alt = "Etherverse";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export function GET() {
  const bg = "#0b0e12";
  const blue = "#00b2ff";
  return new ImageResponse(
    (
      <div
        style={{
          width: "1200px",
          height: "630px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: `radial-gradient(800px 480px at 20% 10%, #0e1320 0%, ${bg} 55%)`,
          color: "white",
          position: "relative",
          fontFamily: "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell",
        }}
      >
        {/* Triangle medallion with eye + infinity glyph */}
        <div style={{ position:"absolute", top:100, left:120, width:200, height:200, border: `4px solid ${blue}`, transform:"rotate(0deg)", borderRadius:12, boxShadow:`0 0 40px ${blue}55` }}/>
        <div style={{ position:"absolute", top:160, left:175, width:90, height:42, borderRadius:"50%", border:`4px solid ${blue}`, boxShadow:`0 0 40px ${blue}55` }}/>
        <div style={{ position:"absolute", top:185, left:210, width:20, height:20, background:blue, borderRadius:"50%", boxShadow:`0 0 30px ${blue}` }}/>

        {/* Title */}
        <div style={{ textAlign:"center" }}>
          <div style={{ fontSize: 64, fontWeight: 800, letterSpacing: .4 }}>
            Etherverse
          </div>
          <div style={{ marginTop: 12, fontSize: 28, opacity: .9 }}>
            Agent Infinity Console
          </div>
        </div>
      </div>
    ),
    { ...size }
  );
}
