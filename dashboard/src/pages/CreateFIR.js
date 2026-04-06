import React, { useState } from "react";

function CreateFIR({ onBack }) {
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    location: "",
    category: "Theft",
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    alert("FIR Created Successfully!\nCase No: FIR-2026-" + Math.floor(Math.random() * 9000 + 1000));
    setFormData({ title: "", description: "", location: "", category: "Theft" });
  };

  return (
    <div className="page-container">
      <header className="page-header">
        <button className="btn-back" onClick={onBack}>← Back</button>
        <h1>📋 Create FIR</h1>
      </header>

      <div className="content-card form-card">
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Title *</label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleChange}
              placeholder="Enter FIR title"
              required
            />
          </div>

          <div className="form-group">
            <label>Category *</label>
            <select
              name="category"
              value={formData.category}
              onChange={handleChange}
            >
              <option>Theft</option>
              <option>Assault</option>
              <option>Property Damage</option>
              <option>Traffic Violation</option>
              <option>Other</option>
            </select>
          </div>

          <div className="form-group">
            <label>Location *</label>
            <input
              type="text"
              name="location"
              value={formData.location}
              onChange={handleChange}
              placeholder="Enter incident location"
              required
            />
          </div>

          <div className="form-group">
            <label>Description *</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              placeholder="Describe the incident"
              rows="5"
              required
            ></textarea>
          </div>

          <button type="submit" className="btn-submit">Create FIR</button>
        </form>
      </div>
    </div>
  );
}

export default CreateFIR;
