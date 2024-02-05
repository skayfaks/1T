import requests
import dill as pickle
import pandas as pd
from flask import Flask, jsonify, request
import __main__
__main__.pd = pd

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def apicall():
    try:
        test_json = request.get_json()
        test = pd.read_json(test_json, orient='records')

    except Exception as e:
        raise e

    clf = 'best_pokemon_model.pk'

    if test.empty:
        return(bad_request())
    else:
        loaded_model = None
        with open('./models/'+clf,'rb') as f:
            loaded_model = pickle.load(f)

        predictions = loaded_model.predict_proba(test)[:, 1]
        prediction_series = list(pd.Series(predictions))
        final_predictions = pd.DataFrame(prediction_series)
        responses = jsonify(predictions=final_predictions.to_json(orient="records"))
        responses.status_code = 200

        return (responses)