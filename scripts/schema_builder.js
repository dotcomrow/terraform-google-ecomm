import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, GraphQLScalarType, GraphQLObjectType } from "graphql";

function main() {
  const options = {
    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
  };
  const bigquery = new BigQuery(options);

  function getTableMetadata(table) {
    async function getTM(table) {
      const metadata = await table.getMetadata();
      return metadata;
    }
    return getTM(table);
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
    

  }
  query();
}
main(...process.argv.slice(2));
