// Applies Kan's drizzle migrations using drizzle-orm's node-postgres migrator.
// It records progress in drizzle.__drizzle_migrations, the same table that
// upstream's `drizzle-kit migrate` (kan-migrate image) uses, so the two are
// interchangeable.
import pg from "pg";
import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";

const pool = new pg.Pool({ connectionString: process.env.POSTGRES_URL, max: 1 });
try {
  console.log("Running database migrations...");
  await migrate(drizzle(pool), { migrationsFolder: "/db/migrations" });
  console.log("Database migrations complete");
} catch (err) {
  console.error("Database migration failed:", err);
  process.exitCode = 1;
} finally {
  await pool.end();
}
