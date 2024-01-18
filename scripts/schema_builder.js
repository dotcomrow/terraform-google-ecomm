import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, GraphQLScalarType, GraphQLObjectType, introspectionFromSchema } from "graphql";
import { Storage } from '@google-cloud/storage';
import fs from 'fs';
import { serializeError } from "serialize-error";

function main() {
  const options = {
    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
    bucket_name: "$3",
  };
  const bigquery = new BigQuery(options);
  const storage = new Storage();
  const fileName = 'graphql_schema.json';

  function getTableMetadata(table) {
    async function getTM(table) {
      const metadata = await table.getMetadata();
      return metadata;
    }
    return getTM(table);
  }

  async function uploadFile() {
    
    generationMatchPrecondition = 0

    const options = {
      destination: destFileName,
      // Optional:
      // Set a generation-match precondition to avoid potential race conditions
      // and data corruptions. The request to upload is aborted if the object's
      // generation number does not match your precondition. For a destination
      // object that does not yet exist, set the ifGenerationMatch precondition to 0
      // If the destination object already exists in your bucket, set instead a
      // generation-match precondition using its generation number.
      preconditionOpts: {ifGenerationMatch: generationMatchPrecondition},
    };

    await storage.bucket(bucket_name).upload(fileName, options);
    console.log(`${filePath} uploaded to ${bucketName}`);
  }

  async function fetchSchemas() {
    const [tables] = await bigquery.dataset(options.datasetId).getTables();

    var tableList = [];
    var graphqlObjects = [];
    for (var table of tables) {
      var tableMetadata = await getTableMetadata(table);
      tableList.push(tableMetadata);
    }

    for (var metadata of tableList) {
      var fields = [];
      metadata[0].schema.fields.forEach((field) => {
        fields[field.name] = {
          type: field.type,
          description: field.description,
        };

        graphqlObjects.push(
          new GraphQLObjectType({
            name: metadata[0].tableReference.tableId,
            fields: fields,
          })
        );
      });
    }

    return graphqlObjects;
  }

  async function query() {
    var schemas = await fetchSchemas();
    const storage = new Storage();
    const schema_json = introspectionFromSchema(schemas);
    let json = JSON.stringify(schema_json);
    fs.writeFile(fileName, json);
    ls -al
  }

  try {
    query();
  } catch (err) {
    const responseError = serializeError(err);
    console.error(responseError);
  }
}
main(...process.argv.slice(2));
