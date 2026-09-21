import random
import statistics
import socket
from datetime import datetime

print("Medical Research Analysis")
print("=========================")

print(f"Running on node: {socket.gethostname()}")
print(f"Started at: {datetime.now()}")

patients = []

for patient_id in range(1, 101):
    age = random.randint(20, 85)
    heart_rate = random.randint(55, 120)
    systolic_bp = random.randint(90, 180)

    risk_score = (
        (age / 85) * 0.4
        + (heart_rate / 120) * 0.3
        + (systolic_bp / 180) * 0.3
    )

    patients.append({
        "id": patient_id,
        "age": age,
        "heart_rate": heart_rate,
        "blood_pressure": systolic_bp,
        "risk_score": risk_score
    })

average_age = statistics.mean(p["age"] for p in patients)
average_hr = statistics.mean(p["heart_rate"] for p in patients)
average_bp = statistics.mean(p["blood_pressure"] for p in patients)

high_risk = [
    p for p in patients
    if p["risk_score"] > 0.75
]

print(f"Patients processed: {len(patients)}")
print(f"Average age: {average_age:.2f}")
print(f"Average heart rate: {average_hr:.2f}")
print(f"Average systolic BP: {average_bp:.2f}")
print(f"High-risk patients: {len(high_risk)}")

print("Analysis completed successfully.")
