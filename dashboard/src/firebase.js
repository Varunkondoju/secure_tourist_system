import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "YOUR API KEY",
  authDomain: "tourist-system-a68df.firebaseapp.com",
  projectId: "tourist-system-a68df",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
export {db};