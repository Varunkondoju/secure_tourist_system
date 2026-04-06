import React, { useEffect, useState, useRef } from "react";
import { db } from "../firebase";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";

function SOSAlerts({ onBack }) {
  const [alerts, setAlerts] = useState([]);
  const audioRef = useRef(null);

  useEffect(() => {
    // 🔔 Load sound
    audioRef.current = new Audio("/siren.mp3");

    const q = query(
      collection(db, "sos"),
      orderBy("createdAt", "desc")
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      // 🔔 Play sound on new alert
      if (data.length > alerts.length) {
        audioRef.current.play().catch(() => {});
      }

      setAlerts(data);
    });

    return () => unsubscribe();
  }, [alerts.length]);

  return (
    <div style={{ padding: "20px", width: "100%" }}>
    <button onClick={onBack} style={{ marginBottom: "10px" }}>← Back</button>
    <h2 style={{ textAlign: "center" }}>🚨 Live SOS Alerts</h2>


      {alerts.length === 0 ? (
        <p style={{ textAlign: "center" }}>No SOS alerts yet</p>
      ) : (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(350px, 1fr))",
            gap: "20px",
            width: "100%",
          }}
        >
          {alerts.map((alert) => {
            let lat = 0;
            let lng = 0;

            if (alert.location) {
              const parts = alert.location.split(",");
              lat = Number(parts[0]);
              lng = Number(parts[1]);
            }

            return (
              <div
                key={alert.id}
                style={{
                  border: "2px solid red",
                  borderRadius: "10px",
                  padding: "15px",
                  backgroundColor: "#fff5f5",
                  width: "100%",
                  overflow: "hidden", // ✅ FIX overflow
                }}
              >
                <p>👤 {alert.fullName || "Unknown"}</p>
                <p>🆔 {alert.digitalId || alert.userId}</p>
                <p>📞 {alert.phone || "No phone"}</p>
                <p>📍 {alert.location}</p>
                <p>Status: {alert.status}</p>

                {/* 🗺️ MAP */}
                {lat && lng ? (
                  <div
                    style={{
                      height: "180px",
                      marginTop: "10px",
                      overflow: "hidden",
                      borderRadius: "10px",
                    }}
                  >
                    <MapContainer
                      center={[lat, lng]}
                      zoom={13}
                      style={{ height: "100%", width: "100%" }}
                    >
                      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                      <Marker position={[lat, lng]}>
                        <Popup>🚨 SOS Location</Popup>
                      </Marker>
                    </MapContainer>
                  </div>
                ) : (
                  <p>⚠️ Invalid location</p>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

export default SOSAlerts;