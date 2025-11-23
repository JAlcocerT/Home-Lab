"use client";

import { FormEvent, useState } from "react";

export default function Home() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [message, setMessage] = useState("");

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setStatus("loading");
    setMessage("");

    try {
      const res = await fetch("/api/subscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) {
        throw new Error(data.error || "Subscription failed");
      }

      setStatus("success");
      setMessage("You are subscribed! Check your inbox.");
      setEmail("");
    } catch (err: any) {
      setStatus("error");
      setMessage(err.message || "Something went wrong.");
    }
  };

  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "radial-gradient(circle at top, #0f172a, #020617)",
        color: "#e5e7eb",
        fontFamily:
          'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
      }}
    >
      <div
        style={{
          maxWidth: 480,
          width: "100%",
          padding: "2.5rem 2rem",
          borderRadius: 16,
          backgroundColor: "rgba(15, 23, 42, 0.9)",
          border: "1px solid #1f2937",
          boxShadow: "0 20px 40px rgba(0,0,0,0.45)",
        }}
      >
        <h1
          style={{
            fontSize: "1.75rem",
            fontWeight: 600,
            marginBottom: "0.5rem",
          }}
        >
          Subscribe to updates
        </h1>
        <p
          style={{
            fontSize: "0.9rem",
            color: "#9ca3af",
            marginBottom: "1.5rem",
          }}
        >
          Enter your email to subscribe via your listmonk instance.
        </p>

        <form
          onSubmit={handleSubmit}
          style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}
        >
          <label
            htmlFor="email"
            style={{ fontSize: "0.8rem", color: "#d1d5db" }}
          >
            Email address
          </label>
          <div style={{ display: "flex", gap: "0.5rem" }}>
            <input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              style={{
                flex: 1,
                padding: "0.5rem 0.75rem",
                borderRadius: 8,
                border: "1px solid #374151",
                backgroundColor: "#020617",
                color: "#e5e7eb",
                fontSize: "0.9rem",
                outline: "none",
              }}
            />
            <button
              type="submit"
              disabled={status === "loading"}
              style={{
                padding: "0.5rem 1rem",
                borderRadius: 8,
                border: "none",
                backgroundColor:
                  status === "loading" ? "#38bdf8aa" : "#38bdf8",
                color: "#020617",
                fontSize: "0.9rem",
                fontWeight: 600,
                cursor: status === "loading" ? "default" : "pointer",
                whiteSpace: "nowrap",
              }}
            >
              {status === "loading" ? "Subscribing…" : "Subscribe"}
            </button>
          </div>

          {message && (
            <p
              style={{
                marginTop: "0.5rem",
                fontSize: "0.85rem",
                color: status === "success" ? "#34d399" : "#f97373",
              }}
            >
              {message}
            </p>
          )}
        </form>
      </div>
    </main>
  );
}
