import Fastify from "fastify";

console.log("start script");

const server = Fastify({
  logger: true,
});

// Declare a route

server.get("/", async (request, reply) => {
  return {
    message: "hello World!",
  };
});

server.get("/ping", async (request, reply) => {
  return "pong";
});
console.log("!!!", JSON.stringify(process.env));
const appPort = +(process.env.PORT || 3000);
// Run the Server!
const start = async () => {
  try {
    server.listen({ port: appPort, host: "0.0.0.0" }, (err) => {
      if (err) throw err;
      console.log(`Server listening on port ${appPort}`);
    });
  } catch (err) {
    server.log.error("!", err);
    process.exit(1);
  }
};
start();
