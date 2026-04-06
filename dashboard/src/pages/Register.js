import React, { useState } from "react";

function Register({ goToLogin }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleRegister = () => {
    // validation (IMPORTANT)
    if (email === "" || password === "") {
      alert("Please fill all fields");
      return;
    }

    // using values (fixes warning)
    console.log("Email:", email);
    console.log("Password:", password);

    alert("Registered Successfully!");
    goToLogin();
  };

  return (
    <div className="page">
      <div className="card">
        <h2>📝 Police Registration</h2>

        <input
          type="email"
          placeholder="Enter Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />

        <input
          type="password"
          placeholder="Enter Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />

        <button onClick={handleRegister}>Register</button>

        <p>
          Already have an account? {" "}
          <span className="link-button" onClick={goToLogin}>
            Login
          </span>
        </p>
      </div>
    </div>
  );
}

export default Register;