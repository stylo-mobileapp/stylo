from .client import get_client


BATCH_SIZE = 100

def save_products(products: list[dict], table_name = "products") -> None:
    print("Saving products to database...")
    client = get_client()

    print("Total batches to save:", (len(products) + BATCH_SIZE - 1) // BATCH_SIZE)

    for i in range(0, len(products), BATCH_SIZE):
        print(f"Saving batch {i // BATCH_SIZE + 1}...")
        batch = products[i:i + BATCH_SIZE]

        batch = list(
            {
                p["url"]: p for p in batch
            }.values()
        )

        client.table(table_name) \
            .upsert(
                batch,
                on_conflict="url"
            ) \
            .execute()