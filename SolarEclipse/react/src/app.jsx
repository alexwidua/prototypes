/**
 
        *  *  *  *  |
     *     *     -- * -- 
    *     *         |*
    *     *          *
     *     *        *
        *  *  *  *

 * @author Alex Widua
 * @date 2023-02-20
 * @license MIT
 */

import { useState } from "react";
import { createRoot } from "react-dom/client";
import { a, useSpring } from "@react-spring/web";
import { useDrag } from "@use-gesture/react";
import "./base.css";

function normalize(value, min, max) {
  return (value - min) / (max - min);
}

function calculateDistance(coordinates1, coordinates2) {
  const h = coordinates1.x - coordinates2.x;
  const v = coordinates1.y - coordinates2.y;
  return Math.sqrt(h * h + v * v);
}

function calculateAngle(coordinates1, coordinates2) {
  let theta = 0;
  const dy = coordinates2.y - coordinates1.y;
  const dx = coordinates2.x - coordinates1.x;
  theta = Math.atan2(dy, dx);
  theta *= 180 / Math.PI;
  // if (theta < offset) theta = 360 + theta;
  return theta;
}

function getGlowLayers(factor, intensity) {
  const glowMap = [1, 2, 7, 14, 24, 42, 86, 124]; // values fine-tuned by hand, just trial & error
  const scale = intensity * factor;
  const glowLayers = Array.from({ length: 8 }, (_, i) => {
    return {
      radius: scale * glowMap[i],
      opacity: i > 0 ? 1 / i : 1,
    };
  });
  return glowLayers;
}

function SolarEclipse() {
  const [theta, setTheta] = useState(0); // angle between moon and sun
  const [obscurity, setObscurity] = useState(0); // TIL: overlap of sun and moon is called 'solar obscuration', or 'obscurity'
  const [beadOpacity, setBeadOpacity] = useState(0);
  const [{ x, y }, api] = useSpring(() => ({ x: -56, y: -56 }));

  const [reflect, setReflect] = useState(0);

  const bind = useDrag(
    ({ down, offset: [ox, oy] }) => {
      const xy = { x: ox, y: oy };
      const distance = Math.abs(calculateDistance(xy, { x: 0, y: 0 }));
      const _theta = calculateAngle(xy, { x: 0, y: 0 }); // calc angle between dragged moon and sun
      const _obscurity = distance < 50 ? normalize(distance, 50, 0) : 0; // when distance is > threshold, calc obscurity (overlap) of moon and sun
      const _beadOpacity = distance < 8 && distance > 2 ? 1 : 0; // when sun and moon almost 100% overlap, calc baily's bead opacity
      setBeadOpacity(_beadOpacity);
      setObscurity(_obscurity);
      setTheta(_theta);
      api.start(xy);
    },
    { from: () => [x.get(), y.get()] }
  );

  const sunStyles = {
    boxShadow: getGlowLayers(obscurity, obscurity, obscurity)
      .map(
        (glow) => `0px 0px ${glow.radius}px rgba(255,255,255,${glow.opacity})`
      )
      .toString(),
  };

  const handleClick = (e) => {
    if (e.target.id === "reflect") return;
    setReflect((x) => x + 1);
  };

  return (
    <div className="container" onClick={handleClick}>
      <div className="sun" style={sunStyles} />
      <a.div
        className="moon"
        style={{ transform: "translate(-50%, -50%)", x, y }}
        {...bind()}
      >
        <div id="reflect" key={reflect} className="reflect" />
      </a.div>
      <BaileysBead theta={theta} offset={0} opa={beadOpacity} />
      <BaileysBead theta={theta} offset={90} opa={beadOpacity} />
      <BaileysBead theta={theta} offset={180} opa={beadOpacity} />
      <BaileysBead theta={theta} offset={270} opa={beadOpacity} />
    </div>
  );
}

/**
 * The Baily's beads effect or diamond ring effect is a feature of total and annular solar eclipses.
 * As the Moon covers the Sun during a solar eclipse, the rugged topography of the lunar limb allows
 * beads of sunlight to shine through in some places while not in others.
 * The effect is named after Francis Baily, who explained the phenomenon in 1836.
 *
 * (Source: Wikipedia)
 */

function BaileysBead({ theta, offset = 0, opa }) {
  const offsetTheta = theta < offset ? 360 + theta : theta;
  const { rotate, opacity } = useSpring({ rotate: offsetTheta, opacity: opa });

  // map opacity 0..1 to angle 0..90..180 (depending on offset)
  const mapOpacityToAngle = () => {
    const rad = (theta - offset) * (Math.PI / 180);
    const cos = Math.cos(rad);
    return cos * -1;
  };

  return (
    <a.div
      className="bead-container"
      style={{
        transform: `translate(-50%, -50%)`,
        rotate: rotate,
        opacity: opacity.to((o) => o * mapOpacityToAngle()),
      }}
    >
      <div className="bead bead-3" />
      <div className="bead bead-2" />
      <div className="bead bead-1" />
    </a.div>
  );
}

createRoot(document.getElementById("root")).render(<SolarEclipse />);
