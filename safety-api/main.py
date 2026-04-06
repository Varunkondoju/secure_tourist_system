from fastapi import FastAPI
import pickle
import numpy as np

app = FastAPI()

# Load model
with open("model.pkl", "rb") as f:
    model = pickle.load(f)

@app.get("/")
def home():
    return {"message": "Safety API running"}

@app.get("/predict")
def predict(lat: float, lon: float):
    lat_grid = round(lat, 2)
    lon_grid = round(lon, 2)

    input_data = np.array([[lat_grid, lon_grid]])

    score = model.predict(input_data)[0]

    return {
        "safety_score": round(float(score), 2)
    }