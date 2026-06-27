// age.jsx — Übersicht widget
// Install path:  ~/Library/Application Support/Übersicht/widgets/age.jsx
//
// Unlike iOS widgets, Übersicht widgets have NO refresh budget, so this renders
// the FULL year/month/day/hour/min/sec breakdown and ticks every second.
//
// Set your date of birth below. NOTE: JS months are 0-indexed (0 = Jan, 7 = Aug).

const BIRTH = new Date(1996, 7, 15, 6, 30, 0); // <-- your DOB (local time)
const NAME  = "My Age";

export const refreshFrequency = 1000; // re-render every second

// Correct calendar breakdown with borrow logic (years / months / days / h:m:s).
function breakdown(birth, now) {
  let y  = now.getFullYear()  - birth.getFullYear();
  let mo = now.getMonth()     - birth.getMonth();
  let d  = now.getDate()      - birth.getDate();
  let h  = now.getHours()     - birth.getHours();
  let mi = now.getMinutes()   - birth.getMinutes();
  let s  = now.getSeconds()   - birth.getSeconds();

  if (s  < 0) { s  += 60; mi--; }
  if (mi < 0) { mi += 60; h--;  }
  if (h  < 0) { h  += 24; d--;  }
  if (d  < 0) { d  += new Date(now.getFullYear(), now.getMonth(), 0).getDate(); mo--; }
  if (mo < 0) { mo += 12; y--;  }

  return { y, mo, d, h, mi, s };
}

const pad = (n) => String(n).padStart(2, "0");

export const render = () => {
  const now = new Date();
  const b = breakdown(BIRTH, now);
  const decimalYears = (now - BIRTH) / (365.2425 * 864e5); // 864e5 = ms per day

  return (
    <div style={{
      fontFamily: "ui-monospace, Menlo, monospace",
      color: "rgba(255,255,255,0.92)",
      textShadow: "0 1px 6px rgba(0,0,0,0.55)",
      lineHeight: 1.35,
      userSelect: "none",
    }}>
      <div style={{ fontSize: 13, opacity: 0.65, letterSpacing: 2 }}>
        {NAME.toUpperCase()}
      </div>
      <div style={{ fontSize: 30, fontWeight: 600 }}>
        {b.y}y {b.mo}m {b.d}d&nbsp;&nbsp;{pad(b.h)}:{pad(b.mi)}:{pad(b.s)}
      </div>
      <div style={{ fontSize: 13, opacity: 0.55, marginTop: 2 }}>
        {decimalYears.toFixed(9)} years
      </div>
    </div>
  );
};

// Position on screen (emotion-style CSS string). z-index 0 keeps it behind windows.
export const className = `
  top: 60px;
  left: 60px;
  z-index: 0;
`;
