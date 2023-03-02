/**
 * @author Alex Widua
 * @date 2023-03-01
 * @license MIT
 */

import React, { useState, useEffect, useRef } from "react";
import { createRoot } from "react-dom/client";
import CursorSVG from "./misc/cursor";
import "./base.css";

function scale(number, inMin, inMax, outMin, outMax) {
  return ((number - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
}

function App() {
  return (
    <>
      <div className="container">
        <Button roughness={0.2} offset={-200}>
          Button
        </Button>
      </div>
      <footer>
        Shiny Button &bull;{" "}
        <a
          href="https://github.com/alexwidua/prototypes"
          target="_blank"
          rel="noopener"
        >
          Github
        </a>
      </footer>
    </>
  );
}
function Button({ roughness = 0, offset = 0, children }) {
  const cameraWidth = 600;
  const cameraHeight = 600;
  const reflectionRef = useRef(null);
  const surfaceReflectionRef = useRef(null);
  const [cameraFacingMode, setCameraFacingMode] = useState("user");
  const detailsContainerRef = useRef(null);
  const [cursorPosition, setCursorPosition] = useState({ x: 0, y: 0 });
  const [buttonFocus, setButtonFocus] = useState(false);
  const [buttonPressed, setButtonPressed] = useState(false);
  const [fingerprints, setFingerprints] = useState([]);
  const mappedRoughness = Math.round(scale(roughness, 0, 1, 0, 16));

  // hacky bandaid solution until I figure out a better fix
  // (in chrome, applying border-radius/overflow:hidden to the .details-container div breaks the mask-image)
  const [showBorderRadius, setShowBorderRadius] = useState(false);
  useEffect(() => {
    if (!navigator.userAgent.includes("Chrome")) {
      setShowBorderRadius(true);
    }
  }, []);

  // set up video stream
  useEffect(() => {
    if (!reflectionRef.current || !surfaceReflectionRef.current) return;
    try {
      let constraints = {
        video: {
          width: {
            ideal: cameraWidth,
          },
          height: {
            ideal: cameraHeight,
          },
          facingMode: cameraFacingMode,
        },
        audio: false,
      };
      navigator.mediaDevices
        .getUserMedia(constraints)
        .then((stream) => {
          const video = reflectionRef.current;
          video.setAttribute("playsinline", "true");
          video.srcObject = stream;
          video.onloadedmetadata = () => {
            video.play();
          };

          const surface = surfaceReflectionRef.current;
          surface.setAttribute("playsinline", "true");
          surface.srcObject = stream;
          surface.onloadedmetadata = () => {
            surface.play();
          };
        })
        .catch((e) => console.log(e));
    } catch (e) {
      console.log(e);
    }
  }, [reflectionRef, surfaceReflectionRef]);

  // track cursor position, used to show cursor reflection and place smudges/"fingerprints"
  useEffect(() => {
    if (!detailsContainerRef.current) return;
    const handleMouseMove = (event) => {
      const rect = detailsContainerRef.current.getBoundingClientRect();
      if (!rect) return;
      setCursorPosition({
        x: event.clientX - rect.x,
        y: event.clientY - rect.y,
      });
    };
    window.addEventListener("mousemove", handleMouseMove);
    return () => {
      window.removeEventListener("mousemove", handleMouseMove);
    };
  }, []);

  // place smudges/"fingerprints"
  const handleMouseDown = (e) => {
    setButtonPressed(true);
    if (!detailsContainerRef.current) return;
    const rect = detailsContainerRef.current.getBoundingClientRect();
    if (!rect) return;
    const fingerprint = { x: e.clientX - rect.x, y: e.clientY - rect.y };
    setFingerprints((fingerprints) => [...fingerprints, fingerprint]);
  };

  return (
    <div
      // className="button-container"
      className={`button-container ${buttonPressed ? "pressed" : null}`}
      onMouseEnter={() => setButtonFocus(true)}
      onMouseLeave={() => setButtonFocus(false)}
    >
      {/* [details-container]: containts cursor reflection and smudges */}
      <div
        className="details-container"
        ref={detailsContainerRef}
        style={{ borderRadius: showBorderRadius ? "var(--border-radius)" : 0 }}
      >
        {/* we need a hacky inner div here to clip the reflective cursor. setting 'overflow: hidden' and 'border-radius' on the parent div 
        negates the '-webkit-mask-image' from the smudges. seems like a bug... */}
        <div className="hacky-cursor-inner-div">
          <div
            className="cursor"
            style={{
              transform: `translate(${cursorPosition.x}px, ${cursorPosition.y}px) translate(-50%, -50%)`,
              opacity: buttonFocus ? 1 : 0,
            }}
          >
            <CursorSVG />
          </div>
        </div>
        {fingerprints.map((el, i) => (
          <div
            className="fingerprint"
            key={i}
            style={{
              transform: `translate(${el.x}px, ${el.y}px) translate(-50%, -50%)`,
            }}
          />
        ))}
      </div>
      {/* show a subtle surface relfection. this emulates light bouncing from the button to the surrounding surface. */}
      <video
        className={`surface-reflection ${buttonPressed ? "pressed" : null}`}
        ref={surfaceReflectionRef}
      />
      <div
        className={`button ${buttonPressed ? "pressed" : null}`}
        onMouseDown={handleMouseDown}
        onMouseUp={() => setButtonPressed(false)}
        onTouchStart={handleMouseDown}
        onTouchEnd={() => setButtonPressed(false)}
      >
        <video
          className="button-reflection"
          ref={reflectionRef}
          style={{
            filter: `blur(${mappedRoughness}px) saturate(0.4) brightness(1.1)`,
            objectPosition: `0px ${offset}px`,
          }}
        />

        <div className="shadow" />
      </div>
      <div className="text">{children}</div>
    </div>
  );
}

createRoot(document.getElementById("root")).render(<App />);
