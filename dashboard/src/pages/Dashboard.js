import React, { useEffect, useState } from "react";
import { getAlerts } from "../services/api";

function Dashboard() {
  const [alerts, setAlerts] = useState([]);

  useEffect(() => {
    getAlerts().then(data => setAlerts(data));
  }, []);

  return (
    <div className="page">
      <div className="card">
        <h2>🚨 Police Dashboard</h2>

        {alerts.length === 0 ? (
          <p>Loading alerts…</p>
        ) : (
          alerts.map((alert, index) => (
            <div key={index} className="alert-card">
              <h3>{alert.user}</h3>
              <p>Location: {alert.location}</p>
              <p>Status: {alert.status}</p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default Dashboard;