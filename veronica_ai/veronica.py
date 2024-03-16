import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler


data = pd.read_csv('transactions.csv')


avg_transaction_amount = data.groupby('sender_ac')['amount'].mean().reset_index()
avg_transaction_count = data.groupby('sender_ac')['transaction_id'].count().reset_index()

avg_transaction_amount.columns = ['sender_ac', 'transaction_amount_avg_amount']
avg_transaction_count.columns = ['sender_ac', 'transaction_count_avg_count']

data = data.merge(avg_transaction_amount, on='sender_ac')
data = data.merge(avg_transaction_count, on='sender_ac')


X = data[['amount', 'transaction_id', 'transaction_amount_avg_amount', 'transaction_count_avg_count']].values
y = data['status'].values


scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)


X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)


model = tf.keras.Sequential([
    tf.keras.layers.Dense(64, activation='relu', input_shape=(X_train.shape[1],)),
    tf.keras.layers.Dense(32, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])


model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])


model.fit(X_train, y_train, epochs=10, batch_size=32, validation_split=0.2)


loss, accuracy = model.evaluate(X_test, y_test)
print(f'Test Loss: {loss}, Test Accuracy: {accuracy}')


predictions = model.predict(X_scaled)
predicted_labels = np.where(predictions < 0.5, 0, 1)


suspicious_transactions = data[predicted_labels == 1]
print("Suspicious Transactions:")
print(suspicious_transactions)
