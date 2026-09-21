import { Router, type IRouter } from "express";
import {
  db,
  branchesTable,
  insertBranchSchema,
  insertResourceSchema,
  insertVenueSchema,
  resourcesTable,
  venuesTable,
} from "@workspace/db";
import {
  CreateBranchBody,
  CreateBranchParams,
  CreateBranchResponse,
  CreateResourceBody,
  CreateResourceParams,
  CreateResourceResponse,
  CreateVenueBody,
  CreateVenueResponse,
} from "@workspace/api-zod";
import { eq } from "drizzle-orm";

const router: IRouter = Router();

function validationError(error: { issues: Array<{ path: PropertyKey[]; message: string }> }) {
  return {
    error: "Request validation failed",
    details: error.issues.map((issue) => ({
      path: issue.path.map(String),
      message: issue.message,
    })),
  };
}

function omitNullValues(record: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(record).filter(([, value]) => value !== null),
  );
}

router.post("/venues", async (req, res): Promise<void> => {
  const parsed = CreateVenueBody.safeParse(req.body);
  if (!parsed.success) {
    req.log.warn({ errors: parsed.error.issues }, "Invalid venue payload");
    res.status(400).json(validationError(parsed.error));
    return;
  }

  const values = insertVenueSchema.parse(parsed.data);
  const [venue] = await db.insert(venuesTable).values(values).returning();
  res.status(201).json(CreateVenueResponse.parse(omitNullValues(venue)));
});

router.post("/venues/:venueId/branches", async (req, res): Promise<void> => {
  const params = CreateBranchParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json(validationError(params.error));
    return;
  }

  const venueId = params.data.venueId;
  const parsed = CreateBranchBody.safeParse(req.body);
  if (!parsed.success) {
    req.log.warn({ errors: parsed.error.issues }, "Invalid branch payload");
    res.status(400).json(validationError(parsed.error));
    return;
  }

  const [venue] = await db
    .select({ id: venuesTable.id })
    .from(venuesTable)
    .where(eq(venuesTable.id, venueId));
  if (!venue) {
    res.status(404).json({ error: "Venue not found" });
    return;
  }

  const values = insertBranchSchema.parse({ ...parsed.data, venueId });
  const [branch] = await db.insert(branchesTable).values(values).returning();
  res.status(201).json(CreateBranchResponse.parse(omitNullValues(branch)));
});

router.post("/branches/:branchId/resources", async (req, res): Promise<void> => {
  const params = CreateResourceParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json(validationError(params.error));
    return;
  }

  const branchId = params.data.branchId;
  const parsed = CreateResourceBody.safeParse(req.body);
  if (!parsed.success) {
    req.log.warn({ errors: parsed.error.issues }, "Invalid resource payload");
    res.status(400).json(validationError(parsed.error));
    return;
  }

  const [branch] = await db
    .select({ id: branchesTable.id })
    .from(branchesTable)
    .where(eq(branchesTable.id, branchId));
  if (!branch) {
    res.status(404).json({ error: "Branch not found" });
    return;
  }

  const parsedValues = insertResourceSchema.parse({ ...parsed.data, branchId });
  const values: typeof resourcesTable.$inferInsert = {
    ...parsedValues,
    metadata: parsedValues.metadata as Record<string, unknown> | undefined,
  };
  const [resource] = await db.insert(resourcesTable).values(values).returning();
  res.status(201).json(CreateResourceResponse.parse(omitNullValues(resource)));
});

export default router;