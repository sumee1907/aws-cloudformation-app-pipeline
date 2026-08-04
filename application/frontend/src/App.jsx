import { useEffect, useState } from "react";
import "./App.css";

function App() {
  const [backendData, setBackendData] = useState(null);
  const [error, setError] = useState("");

  async function getBackendTime() {
    try {
      const response = await fetch("/api/time");

      if (!response.ok) {
        throw new Error(`Backend returned HTTP ${response.status}`);
      }

      const data = await response.json();

      setBackendData(data);
      setError("");
    } catch (requestError) {
      console.error("Backend request failed:", requestError);

      setBackendData(null);
      setError("Unable to connect to the Node.js backend.");
    }
  }

  useEffect(() => {
    getBackendTime();

    const intervalId = window.setInterval(getBackendTime, 1000);

    return () => {
      window.clearInterval(intervalId);
    };
  }, []);

  return (
    <main className="page">
      <section className="card">
        <p className="program-name">
          Cloud Computing and DevOps Certification Program
        </p>

        <p className="project-name">Course End Project</p>

        <h1>{backendData?.message ?? "Hello World!"}</h1>

        {backendData && (
          <>
            <p className="current-time">{backendData.currentTime}</p>

            <div className="connection-status">
              <span className="status-indicator" />
              Backend Connected
            </div>
          </>
        )}

        {error && (
          <div className="error-panel">
            <p>{error}</p>

            <button type="button" onClick={getBackendTime}>
              Try Again
            </button>
          </div>
        )}
      </section>
    </main>
  );
}

export default App;