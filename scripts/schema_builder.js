import { BigQuery } from "@google-cloud/bigquery";

function main() {
  const options = {
    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
  };
  const bigquery = new BigQuery(options);

  async function query() {
    
    const [tables] = await bigquery.dataset(options.datasetId).getTables();

    tables.forEach(table => {
      table.schema.fields.forEach(field => {
        console.log(field.name);
        console.log(field.type);
      });
    });

    // const query = "SELECT name FROM \`bigquery-public-data.usa_names.usa_1910_2013\` WHERE state = 'TX' LIMIT 100";

    // // For all options, see https://cloud.google.com/bigquery/docs/reference/rest/v2/jobs/query
    // const options = {
    //   query: query,
    //   // Location must match that of the dataset(s) referenced in the query.
    //   location: "US",
    // };

    // // Run the query as a job
    // const [job] = await bigquery.createQueryJob(options);

    // // Wait for the query to finish
    // const [rows] = await job.getQueryResults();

    // // Print the results
    // console.log("Rows:");
    // rows.forEach((row) => console.log(row));
  }
  // [END bigquery_query]
  query();
}
main(...process.argv.slice(2));
