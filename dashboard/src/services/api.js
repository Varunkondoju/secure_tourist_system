const BASE_URL = "http://localhost:3000";

export const getAlerts = async () => {
  const res = await fetch(`${BASE_URL}/alerts`);
  return res.json();
};