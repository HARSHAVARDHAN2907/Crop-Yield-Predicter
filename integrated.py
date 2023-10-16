from flask import Flask, request, jsonify, send_from_directory
import sys
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
import shutil
import random
import os

app = Flask(__name__)

# Load historical weather data from a CSV file
# Replace 'weather_data.csv' with the actual filename and path of your historical weather data
data = pd.read_csv('weatherHistory.csv')

# Separate the data into features (X) and target variables (y)
X = data[['YEAR']]
y_temp = data['ANNUAL']
y_rainfall = data['Rainfall']

# Create and fit the linear regression model for temperature prediction
model_temp = LinearRegression()
model_temp.fit(X, y_temp)

# Create and fit the linear regression model for rainfall prediction
model_rainfall = LinearRegression()
model_rainfall.fit(X, y_rainfall)

# Function to predict temperature and rainfall for a given year
def predict_weather(year):
    predicted_temperature = model_temp.predict([[year]])[0]
    predicted_rainfall = model_rainfall.predict([[year]])[0]
    return predicted_temperature, predicted_rainfall

def process_data(data1):
    result = data1

    try:
        input_year = int(data1)
        predicted_temperature, predicted_rainfall = predict_weather(input_year)
    
        crop_list = [42, 50, 67, 85, 95, 125, 175, 200]
        crop_list_names = {
            42: "Pulses Lentils",
            50: "Wheat Bajra",
            67: "GroundNuts",
            85: "Cotton",
            95: "Maize",
            125: "Rice Sugarcane",
            175: "Tea Coffee",
            200: "Rubber"
        }
        total_value = 0
        crop_list_diff = []  # Change to a list
        
        crop_min_list = {}
    
        for i in crop_list:
            sum = int(round(predicted_rainfall)) - i
            if sum > 0:
                crop_list_diff.append(sum)
                total_value += sum
                crop_min_list.update({i: sum})
            else:
                total_value += (sum * -1)
                crop_list_diff.append(sum * -1)
                crop_min_list.update({i: sum * -1})

        percent_value = []
        total_per = 0
    
        for key, value in crop_min_list.items():
            percent_value.append((total_value - value))
            total_per += (total_value - value)

        percent_name = []
        final_percent = []
    
        for i in percent_value:
            final_percent.append(round(((i / total_per) * 100), 2))
        final_percent.sort()    

        print("THE FOLLOWING CROPS ARE CATEGORIZED FROM THE MINIMUM TO BEST YIELD")
        crop_min_list_sorted = dict(sorted(crop_min_list.items(), key=lambda item: item[1]))
    
        for key, value in crop_min_list_sorted.items():
            percent_name.append(crop_list_names[key])
        percent_name.sort(reverse=True)
    
        for i in range(0, len(percent_name)):
            print(percent_name[i], "-", final_percent[i], "%")
    
        crop_diff_min = min(crop_list_diff)
        crop_diff_min_index = crop_list_diff.index(crop_diff_min)
        crop_list_result = crop_list[crop_diff_min_index]

        # Create the pie chart
        y = final_percent
        mylabels = percent_name
        plt.pie(y, labels=mylabels, autopct='%1.1f%%', startangle=140)
        plt.axis('equal')

        # Save the pie chart to an image file (optional

        file_name = f'pie_chart_{input_year}.png'
        plt.savefig(file_name)
        plt.close()  # Close the plot

        # Move the generated image to a publicly accessible folder (replace 'image_folder' with your actual path)
        image_folder = 'E:\\Flutter files\\MINI_PROJECT'  # Update with your image folder path
        destination_path = os.path.join(image_folder, file_name)
        if shutil.move(file_name, destination_path):
            print("Image saved successfully")
            return destination_path  # Return the image URL

    except ValueError:
        print("Invalid input. Please enter a valid year as an integer.")

@app.route('/get_latest_image_filename')
def get_latest_image_filename():
    image_files = os.listdir('E:\\Flutter files\\MINI_PROJECT')
    print(image_files)
    if image_files:
        latest_image_filename = max(image_files, key=os.path.getctime)
        print(latest_image_filename)
        return jsonify({"latest_image_filename": latest_image_filename}), 200
    else:
        return jsonify({"latest_image_filename": ""}), 404
    
@app.route('/get_image/<filename>')
def get_image(filename):
    return send_from_directory('E:/Flutter files/MINI_PROJECT/', filename)

@app.route('/get_send_string', methods=['POST'])
def get_data():
    data = request.form
    # Process data or perform some Python logic here
    data1 = data['topic']
    result = process_data(data1)
    
    if result:
        response = {
            "message": "Data received successfully",
            "data": data,
            "image_url": result  # Include the image URL in the response
        }
        return jsonify(response), 200
    else:
        return jsonify({"message": "Error processing data"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
