import React, { useEffect, useState } from "react";
import { db } from "../firebase";
import { collection, onSnapshot, query, orderBy } from "firebase/firestore";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";

function EFIR({ onBack }) {
  const [firs, setFirs] = useState([]);

  useEffect(() => {
    const q = query(
      collection(db, "efir"), // ✅ correct collection
      orderBy("createdAt", "desc")
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      setFirs(data);
    });

    return () => unsubscribe();
  }, []);

  return (
    <div style={{ padding: "20px", width: "100%" }}>
      
      {/* 🔙 BACK BUTTON */}
      <button
        onClick={onBack}
        style={{
          marginBottom: "20px",
          padding: "10px 15px",
          borderRadius: "8px",
          border: "none",
          backgroundColor: "#ddd",
          cursor: "pointer"
        }}
      >
        ← Back
      </button>

      <h2 style={{ textAlign: "center" }}>📄 Live E-FIR Alerts</h2>

      {firs.length === 0 ? (
        <p style={{ textAlign: "center" }}>No FIRs found</p>
      ) : (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(350px, 1fr))",
            gap: "20px",
            width: "100%",
          }}
        >
          {firs.map((fir, index) => {
            let lat = 0;
            let lng = 0;

            // ✅ FIX location parsing
            if (fir.location && fir.location.includes(",")) {
              const parts = fir.location.split(",");
              lat = Number(parts[0]);
              lng = Number(parts[1]);
            }

            return (
              <div
                key={fir.id}
                style={{
                  border: index === 0 ? "2px solid red" : "2px solid #2196f3",
                  borderRadius: "10px",
                  padding: "15px",
                  backgroundColor: "#fff",
                  width: "100%",
                  overflow: "hidden",
                }}
              >
                {/* 👤 NAME */}
                <p>👤 {fir.fullName || "Unknown"}</p>

                {/* 🆔 DIGITAL ID */}
                <p>🆔 {fir.digitalId || "N/A"}</p>

                <p>📞 {fir.phone || "No phone"}</p>

                {/* 📝 DESCRIPTION */}
                <p>📝 {fir.description}</p>

                {/* 📍 LOCATION */}
                <p>📍 {fir.location}</p>

                {/* 🚨 STATUS */}
                <p>Status: {fir.status}</p>

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
                        <Popup>📄 FIR Location</Popup>
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

export default EFIR;