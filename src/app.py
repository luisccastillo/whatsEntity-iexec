import os
import sys
import json
import spacy

input_directory = os.environ['IEXEC_IN']
output_directory = os.environ['IEXEC_OUT']
input_filename = os.environ['IEXEC_DATASET_FILENAME']

nlp = spacy.load("en_core_web_trf", disable=[
                 "tok2vec", "tagger", "parser", "attribute_ruler", "lemmatizer"])


def find_entities(message_line):
    for entity in nlp(message_line).ents:
        if (entity.label_ == "ORG"):
            organizations.add(entity.text)
        if (entity.label_ == "GPE"):
            locations.add(entity.text)


if __name__ == '__main__':
    organizations = set()
    locations = set()
    begin_timestamp = None
    end_timestamp = None
    line_count = 0

    # process file
    path = os.path.join(input_directory, input_filename)
    print("Reading " + path)
    if os.path.exists(path):
        with open(path, 'r') as input_file:
            print("The input file has been loaded")
            begin_timestamp = input_file.readline()[1:21]
            for message_line in input_file:
                line_count += 1
                find_entities(message_line[23:])  # slice timestamp for nlp
            end_timestamp = message_line[1:21]

    # generate result
    result = {}
    result['filename'] = input_filename
    result['line_count'] = line_count
    result['begin_timestamp'] = begin_timestamp.replace(',', '')
    result['end_timestamp'] = end_timestamp.replace(',', '')
    result['locations'] = list(locations)
    result['organizations'] = list(organizations)

    # save result
    with open(os.path.join(output_directory, "result.json"), 'w+') as f:
        json.dump(result, f)
    with open(os.path.join(output_directory, "computed.json"), 'w+') as f:
        json.dump(
            {"deterministic-output-path": os.path.join(output_directory, "result.json")}, f)
