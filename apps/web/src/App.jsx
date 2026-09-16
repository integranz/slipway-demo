import { useEffect, useState } from "react";
import { webVersion, sameRelease } from "./version.js";

export default function App() {
  const [health, setHealth] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Same-origin: nginx (container) or the Vite dev proxy forwards /api/* to the API app, which serves /api/health.
    fetch("/api/health").then(async (r) => {
      if (!r.ok) throw new Error(`API responded ${r.status}`);
      setHealth(await r.json());
    }).catch((e) => setError(e.message));
  }, []);

  return (
    <main style={{ fontFamily: "system-ui, sans-serif", maxWidth: 640, margin: "4rem auto", padding: "0 1rem" }}>
      <h1>slipway demo</h1>
      <p>Frontend version <code>{webVersion}</code></p>
      {health && (
        <p>
          API <code>{health.status}</code>, version <code>{health.version}</code>
          {sameRelease(health.version, webVersion) ? " (same release)" : " (different release)"}
        </p>
      )}
      {error && <p role="alert">API unreachable: {error}</p>}
    </main>
  );
}
