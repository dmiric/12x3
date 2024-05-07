const dotenv = require("dotenv");

let ENV_FILE_NAME = "";
console.log('Node ENV', process.env.NODE_ENV)
switch (process.env.NODE_ENV) {
  case "production":
    ENV_FILE_NAME = ".env.production";
    break;
  case "staging":
    ENV_FILE_NAME = ".env.staging";
    break;
  case "test":
    ENV_FILE_NAME = ".env.test";
    break;
  case "development":
    ENV_FILE_NAME = ".env.development";
    break;
  case "codespace":
    ENV_FILE_NAME = ".env.codespace";
    break;
  default:
    ENV_FILE_NAME = ".env";
    break;
}

try {
  if(!ENV_FILE_NAME) {
    dotenv.config({ path: process.cwd() + "/" + ENV_FILE_NAME });
  }
} catch (e) {}

// CORS when consuming Medusa from admin
const ADMIN_CORS =
  process.env.ADMIN_CORS || "http://localhost:7001";

const MEDUSA_BACKEND_URL =
process.env.MEDUSA_BACKEND_URL || "http://localhost:9000";
const MEDUSA_ADMIN_BACKEND_URL =
process.env.MEDUSA_ADMIN_BACKEND_URL || "http://localhost:9000";

// CORS to avoid issues when consuming Medusa from a client
const STORE_CORS = process.env.STORE_CORS || "http://localhost:8000";
const DB_USERNAME = process.env.DB_USERNAME
const DB_PASSWORD = process.env.DB_PASSWORD
const DB_HOST = process.env.DB_HOST
const DB_PORT = process.env.DB_PORT
const DB_DATABASE = process.env.DB_DATABASE
const DB_SSL = process.env.DB_SSL

const DATABASE_URL = 
   `postgres://${DB_USERNAME}:${DB_PASSWORD}` + 
   `@${DB_HOST}:${DB_PORT}/${DB_DATABASE}?ssl=${DB_SSL}`
if(!ENV_FILE_NAME) {
  const DATABASE_URL = process.env.DB_URL
}

const REDIS_URL = process.env.REDIS_URL || "redis://localhost:6379";

const plugins = [
  `medusa-fulfillment-manual`,
  `medusa-payment-manual`,
  {
    resolve: `@medusajs/file-local`,
    options: {
      upload_dir: "uploads",
      backend_url: "https://seal-app-aqdpj.ondigitalocean.app"
    },
  },
  {
    resolve: "@medusajs/admin",
    /** @type {import('@medusajs/admin').PluginOptions} */
    options: {
      autoRebuild: true,
      // serve: process.env.NODE_ENV === "development",
      serve: false,
      backend: MEDUSA_BACKEND_URL,
      path: "/",
      outDir: "build",
      develop: {
        port: 7001,
        logLevel: "error",
        stats: "normal",
        allowedHosts: "all",
        webSocketURL: undefined,
        //open: process.env.OPEN_BROWSER !== "false",
        open: false
      },
    },
  }
];

const modules = {
   eventBus: {
    resolve: "@medusajs/event-bus-redis",
    options: {
      redisUrl: REDIS_URL
    }
  },
  cacheService: {
    resolve: "@medusajs/cache-redis",
    options: {
      redisUrl: REDIS_URL
    }
  },
};

/** @type {import('@medusajs/medusa').ConfigModule["projectConfig"]} */
const projectConfig = {
  jwtSecret: process.env.JWT_SECRET,
  cookieSecret: process.env.COOKIE_SECRET,
  store_cors: STORE_CORS,
  database_url: DATABASE_URL,
  admin_cors: ADMIN_CORS,
  database_extra: { ssl: { rejectUnauthorized: false } },
  redis_url: process.env.REDIS_URL,
};

console.log(ADMIN_CORS)

/** @type {import('@medusajs/medusa').ConfigModule} */
module.exports = {
  projectConfig,
  plugins,
  modules,
};
