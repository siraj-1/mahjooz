import { createInsertSchema } from "drizzle-zod";
import { pgTable, text, timestamp, uuid, doublePrecision } from "drizzle-orm/pg-core";
import { z } from "zod/v4";
import { venuesTable } from "./venues";

export const branchesTable = pgTable("branches", {
  id: uuid("id").primaryKey().defaultRandom(),
  venueId: uuid("venue_id")
    .notNull()
    .references(() => venuesTable.id, { onDelete: "cascade" }),
  name: text("name").notNull(),
  code: text("code"),
  description: text("description"),
  address: text("address"),
  city: text("city"),
  country: text("country"),
  timezone: text("timezone"),
  contactPhone: text("contact_phone"),
  latitude: doublePrecision("latitude"),
  longitude: doublePrecision("longitude"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export const insertBranchSchema = createInsertSchema(branchesTable).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});
export type InsertBranch = z.infer<typeof insertBranchSchema>;
export type Branch = typeof branchesTable.$inferSelect;