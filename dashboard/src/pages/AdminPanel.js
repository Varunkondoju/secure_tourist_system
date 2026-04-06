import React from "react";
import "../styles/AdminPanel.css";

function AdminPanel({ onNavigate, onLogout, user }) {
  const menuItems = [
    { id: "sos-alerts", label: "SOS Alerts", icon: "🆘" },
    { id: "e-fir", label: "E-FIR", icon: "📝" },
  ];

  return (
    <div className="admin-panel">
      {/* Header */}
      <header className="admin-header">
        <div className="logo-section">
          <h1>Admin Panel</h1>
        </div>
        <div className="header-buttons">
          <div className="user-profile">
            <span className="user-name">{user ? user.name : "User"}</span>
            <span className="user-email">{user ? user.email : ""}</span>
          </div>
          <button className="btn-logout" onClick={onLogout}>
            Logout
          </button>
        </div>
      </header>

      {/* Police Emblem */}
      <div className="emblem-container">
        <img
          src="https://as1.ftcdn.net/jpg/13/26/84/30/1000_F_1326843005_QFbIvFeqprjG7kCmkWzY6kqUgBM0V6bx.webp"
          alt="Indian Police Emblem"
          className="police-emblem"
        />
      </div>

      {/* Menu Grid */}
      <div className="menu-grid">
        {menuItems.map((item) => (
          <button
            key={item.id}
            className="menu-card"
            onClick={() => onNavigate(item.id)}
          >
            <span className="menu-icon">{item.icon}</span>
            <span className="menu-label">{item.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

export default AdminPanel;
