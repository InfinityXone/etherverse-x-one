"use client";
type Props = { size?: number; className?: string };
export default function Logo({ size=32, className="" }: Props) {
  return (
    <div className={`relative inline-flex items-center justify-center ${className}`} style={{ width:size, height:size }}>
      <img src="/logo.png" width={size} height={size} alt="Infinity" className="select-none pointer-events-none rounded" draggable={false}/>
      <span className="logo-glow rounded" />
    </div>
  );
}
