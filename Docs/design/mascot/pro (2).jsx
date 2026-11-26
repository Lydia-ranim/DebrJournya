import React, { useEffect, useRef, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { BotAvatarSim, drawBotAvatarFrame, autoInk, BOT_AVATAR_OVERSCAN, BOT_AVATAR_RISE } from 'bot-avatars';

const C = { soot: '#2D3536', moss: '#697C70', euc: '#98AA9D', mist: '#B3C9D6', plaster: '#F2EFE2', ink: '#111414', ink2: '#3E4544', card: '#FFFFFF', line: '#E9E5DA', bg: '#FAF8F2', dark: '#0E1412', darkCard: '#161E1B' };

// Body: a wide case. Handle drawn as its own solid behind the body (parts), with a hole.
const BODY = 'M14 34 H86 Q95 34 95 43 V77 Q95 86 86 86 H14 Q5 86 5 77 V43 Q5 34 14 34 Z';
const HANDLE = 'M37 37 V27 Q37 19 45 19 H55 Q63 19 63 27 V37 H57.5 V28.5 Q57.5 25 54 25 H46 Q42.5 25 42.5 28.5 V37 Z';

const METALS = {
  brass: ['#F3DFA6', '#C9A35A', '#8A6A2E'],
  steel: ['#F4F6F6', '#AEB6B8', '#5E676A'],
};

function rr(ctx, x, y, w, h, r) { ctx.beginPath(); ctx.roundRect(x, y, w, h, r); }

// Front details, drawn in body-box units (0–100) after the library's frame.
function drawDetails(ctx, t, pose, o) {
  const m = METALS[o.metal];
  // stitching inset round the front panel
  ctx.save();
  ctx.setLineDash([2.2, 2.2]); ctx.lineWidth = 0.9; ctx.strokeStyle = o.stitch;
  rr(ctx, 10, 39, 80, 42, 6); ctx.stroke();
  ctx.restore();
  if (o.metalParts) {
  // latches on the top edge
  for (const lx of [22, 78]) {
    const g = ctx.createLinearGradient(0, 35, 0, 44);
    g.addColorStop(0, m[0]); g.addColorStop(0.55, m[1]); g.addColorStop(1, m[2]);
    ctx.fillStyle = g; rr(ctx, lx - 5.5, 35.5, 11, 8, 2); ctx.fill();
    ctx.fillStyle = 'rgba(0,0,0,.25)'; rr(ctx, lx - 2, 39.5, 4, 2.2, 1); ctx.fill();
    ctx.fillStyle = 'rgba(255,255,255,.7)'; rr(ctx, lx - 4, 36.3, 8, 1.2, 0.6); ctx.fill();
  }
  // corner guards at the bottom
  for (const [cx, flip] of [[9, 1], [91, -1]]) {
    ctx.save(); ctx.translate(cx, 82); ctx.scale(flip, 1);
    const g = ctx.createLinearGradient(0, -6, 0, 4);
    g.addColorStop(0, m[1]); g.addColorStop(1, m[2]);
    ctx.fillStyle = g; ctx.beginPath(); ctx.moveTo(-4, -6); ctx.lineTo(3, -6); ctx.quadraticCurveTo(4, -6, 4, -5);
    ctx.lineTo(4, 0); ctx.quadraticCurveTo(4, 4, 0, 4); ctx.lineTo(-4, 4); ctx.closePath(); ctx.fill();
    ctx.restore();
  }
  }
  // notepad + pen, held at the lower front
  const writing = pose.w[1];
  const side = o.padSide === 'right' ? 1 : -1;
  ctx.save();
  ctx.translate(50 + side * 36, 78); ctx.rotate(side * -0.22);
  ctx.fillStyle = 'rgba(17,20,20,.18)'; rr(ctx, -11.5, -12.5, 25, 30, 2.5); ctx.fill();
  ctx.fillStyle = '#FFFDF6'; rr(ctx, -12.5, -14, 25, 30, 2.5); ctx.fill();
  ctx.strokeStyle = 'rgba(17,20,20,.12)'; ctx.lineWidth = 0.5; ctx.stroke();
  ctx.fillStyle = o.padTop; rr(ctx, -12.5, -14, 25, 5, [2.5, 2.5, 0, 0]); ctx.fill();
  ctx.fillStyle = 'rgba(255,255,255,.65)';
  for (let i = -9; i <= 9; i += 4.5) { ctx.beginPath(); ctx.arc(i, -11.5, 0.9, 0, 7); ctx.fill(); }
  ctx.strokeStyle = '#B3C9D6'; ctx.lineWidth = 0.7;
  const scribble = Math.min(1, ((t * 0.35) % 1.4)) * writing + (1 - writing) * 0.75;
  for (let r = 0; r < 4; r++) {
    const y = -4 + r * 4.6; ctx.beginPath(); ctx.moveTo(-9, y); ctx.lineTo(9, y); ctx.stroke();
  }
  // handwriting
  ctx.strokeStyle = '#2D3536'; ctx.lineWidth = 0.75; ctx.lineCap = 'round';
  for (let r = 0; r < 3; r++) {
    const len = r === 2 ? 10 * scribble : 16;
    ctx.beginPath(); ctx.moveTo(-8.5, -5.2 + r * 4.6);
    for (let x = 0; x <= len; x += 0.8) ctx.lineTo(-8.5 + x, -5.2 + r * 4.6 - Math.abs(Math.sin(x * 1.9 + r)) * 1.3);
    ctx.stroke();
  }
  // pen: writes while working
  const px = -8.5 + 10 * scribble * writing + (1 - writing) * 5, py = 3.7 - 1.5;
  const wig = writing * Math.sin(t * 22) * 0.8;
  ctx.translate(px + wig, py + Math.abs(wig) * 0.5); ctx.rotate(-0.85);
  const pg = ctx.createLinearGradient(0, -1.6, 0, 1.6);
  pg.addColorStop(0, '#4A5556'); pg.addColorStop(0.5, '#2D3536'); pg.addColorStop(1, '#141A1B');
  ctx.fillStyle = '#D9D4C4'; ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(4, -1.4); ctx.lineTo(4, 1.4); ctx.closePath(); ctx.fill();
  ctx.fillStyle = '#111414'; ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(1.3, -0.45); ctx.lineTo(1.3, 0.45); ctx.closePath(); ctx.fill();
  ctx.fillStyle = pg; rr(ctx, 4, -1.6, 17, 3.2, 1.4); ctx.fill();
  if (o.metalParts) { ctx.fillStyle = METALS[o.metal][1]; rr(ctx, 15, -1.75, 2, 3.5, 0.6); ctx.fill(); }
  ctx.fillStyle = '#98AA9D'; rr(ctx, 17, -1.6, 4.4, 3.2, [0, 1.4, 1.4, 0]); ctx.fill();
  ctx.restore();
}

function Jobby({ size = 160, state = 'default', o, theme = 'light', paused = false }) {
  const ref = useRef(null);
  const stRef = useRef(state);
  stRef.current = state;
  useEffect(() => {
    const cv = ref.current; const dpr = Math.min(2, window.devicePixelRatio || 1);
    const W = size * BOT_AVATAR_OVERSCAN; cv.width = W * dpr; cv.height = W * dpr;
    const ctx = cv.getContext('2d');
    const sim = new BotAvatarSim(Math.random(), stRef.current);
    const cfg = {
      path: new Path2D(BODY), parts: [new Path2D(HANDLE)], partsDepth: 0.55, face: 'mouth', faceX: 50, faceY: 55, faceScale: 0.95,
      color: o.color, ink: autoInk(o.color), shading: 'plastic', typeKey: 'jobby-case', dpr, theme, depth: 0.8, roundness: 0.55,
      wear: { hat: 'none', glasses: 'round', headphones: false, bowTie: true, color: C.soot },
    };
    let last = performance.now(), t = 0, raf;
    const frame = (now) => {
      const dt = Math.min(0.05, (now - last) / 1000); last = now; t += dt;
      if (sim.state !== stRef.current) sim.setState(stRef.current);
      if (!paused) sim.update(dt);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0); ctx.clearRect(0, 0, W, W);
      drawBotAvatarFrame(ctx, size, sim.pose, cfg);
      const p = sim.pose; const facing = Math.cos(p.yaw);
      if (facing > 0.15) {
        const k = size / 100;
        ctx.save();
        ctx.translate(W / 2 + p.x * k, W / 2 + BOT_AVATAR_RISE * size + p.y * k);
        ctx.rotate(p.roll);
        ctx.scale(p.sx * k * facing, p.sy * k * Math.cos(p.pitch));
        ctx.translate(-50 + Math.sin(p.yaw) * 22, -50 - Math.sin(p.pitch) * 22);
        ctx.globalAlpha = Math.min(1, (facing - 0.15) * 4);
        drawDetails(ctx, t, p, o);
        ctx.restore();
      }
      raf = requestAnimationFrame(frame);
    };
    raf = requestAnimationFrame(frame);
    const poke = () => sim.poke();
    cv.addEventListener('click', poke);
    return () => { cancelAnimationFrame(raf); cv.removeEventListener('click', poke); };
  }, [size, o, theme, paused]);
  const W = size * BOT_AVATAR_OVERSCAN, off = (W - size) / 2;
  return <canvas ref={ref} role="img" aria-label="Jobby, la mascotte" style={{ width: W, height: W, margin: `${-off - BOT_AVATAR_RISE * size}px ${-off}px ${-off + BOT_AVATAR_RISE * size}px`, cursor: 'pointer', display: 'block' }} />;
}

const VARIANTS = [
  { id: 'v2', name: 'Jobby Pro', note: 'Mallette mousse sans pièces métalliques : poignée, surpiqûres, lunettes rondes, nœud, bloc-notes et stylo.', o: { color: '#5F8069', metal: 'steel', metalParts: false, padSide: 'left', padTop: C.soot, stitch: 'rgba(255,255,255,.35)' } },
];

function Seg({ value, options, onChange, label }) {
  return (
    <div role="group" aria-label={label} style={{ display: 'inline-flex', gap: 4, padding: 4, background: '#EFECE3', borderRadius: 12 }}>
      {options.map(([v, l]) => (
        <button key={v} type="button" aria-pressed={value === v} onClick={() => onChange(v)}
          style={{ border: 'none', cursor: 'pointer', padding: '8px 14px', borderRadius: 9, fontWeight: value === v ? 800 : 600, fontSize: 14, fontFamily: 'inherit',
            background: value === v ? C.card : 'transparent', color: value === v ? C.ink : C.ink2, boxShadow: value === v ? '0 1px 3px rgba(45,53,54,.18)' : 'none' }}>{l}</button>
      ))}
    </div>
  );
}

function Card({ v }) {
  const [state, setState] = useState('working');
  return (
    <article style={{ background: C.card, border: `1px solid ${C.line}`, borderRadius: 24, padding: 20, display: 'flex', flexDirection: 'column', gap: 16 }}>
      <div style={{ background: C.bg, borderRadius: 18, height: 300, display: 'flex', alignItems: 'center', justifyContent: 'center', paddingTop: 30 }}>
        <Jobby size={190} state={state} o={v.o} />
      </div>
      <div><h2 style={{ margin: 0, fontSize: 22, fontWeight: 800 }}>{v.name}</h2>
        <p style={{ margin: '6px 0 0', fontSize: 14, lineHeight: '21px', color: C.ink2 }}>{v.note}</p></div>
      <Seg label={`État de ${v.name}`} value={state} onChange={setState} options={[['default', 'Au repos'], ['working', 'Prend des notes'], ['sleeping', 'Endormi']]} />
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        <div style={{ background: C.bg, border: `1px solid ${C.line}`, borderRadius: 14, padding: '26px 12px 12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 16 }}>
          <Jobby size={64} o={v.o} /><Jobby size={36} o={v.o} /></div>
        <div style={{ background: C.dark, borderRadius: 14, padding: '26px 12px 12px', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 16 }}>
          <Jobby size={64} o={v.o} theme="dark" /><Jobby size={36} o={v.o} theme="dark" /></div>
      </div>
    </article>
  );
}

function App() {
  return (
    <main style={{ maxWidth: 1180, margin: '0 auto', padding: '40px 20px 60px' }}>
      <div style={{ fontSize: 14, fontWeight: 700, color: C.moss, letterSpacing: '.05em', textTransform: 'uppercase' }}>DebrJournya</div>
      <h1 style={{ margin: '4px 0 0', fontSize: 34, fontWeight: 800, letterSpacing: '-0.02em' }}>Jobby Pro, la mascotte</h1>
      <p style={{ margin: '6px 0 26px', color: C.ink2, fontSize: 15, maxWidth: 760, lineHeight: '23px' }}>Une vraie mallette : poignée en volume et surpiqûres. Il garde ses lunettes rondes et son nœud, et tient un bloc-notes avec un stylo : en mode « Prend des notes », il écrit. Clique dessus pour le faire sauter.</p>
      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 560px)', gap: 20 }}>
        {VARIANTS.map((v) => <Card key={v.id} v={v} />)}
      </div>
    </main>
  );
}

const still = location.hash.match(/^#still-(default|working|sleeping)-(v2)$/);
createRoot(document.getElementById('root')).render(still
  ? <div style={{ padding: 160, display: 'inline-block' }}><Jobby size={240} paused state={still[1]} o={VARIANTS.find((v) => v.id === still[2]).o} /></div>
  : <App />);
