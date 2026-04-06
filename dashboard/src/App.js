import React, { useState } from "react";
import AdminPanel from "./pages/AdminPanel";
import SOSAlerts from "./pages/SOSAlerts";
import EFIR from "./pages/EFIR";
import CreateFIR from "./pages/CreateFIR";
import Login from "./pages/Login";
import Register from "./pages/Register";
import "./App.css";

function App() {
  const [page, setPage] = useState("login");

  const user = {
    email: "police@gmail.com",
    name: "Police Officer"
  };

  const handleNavigate = (newPage) => {
    setPage(newPage);
  };

  const handleLogout = () => {
    setPage("login");
  };

  return (
    <div className="App">
      {page === "login" && (
        <Login
          onLogin={() => setPage("admin")}
          goToRegister={() => setPage("register")}
        />
      )}

      {page === "register" && (
        <Register goToLogin={() => setPage("login")} />
      )}

      {page === "admin" && (
        <AdminPanel
          onNavigate={handleNavigate}
          onLogout={handleLogout}
          user={user}
        />
      )}

      {page === "sos-alerts" && (
        <SOSAlerts onBack={() => setPage("admin")} />
      )}

      {page === "e-fir" && <EFIR onBack={() => setPage("admin")} />}

      {page === "create-fir" && (
        <CreateFIR onBack={() => setPage("admin")} />
      )}
    </div>
  );
}

export default App;