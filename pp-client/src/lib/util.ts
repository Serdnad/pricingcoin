/**
 * "Shortens" strings past a fixed length by replacing the middle
 * section with ellipsis.
 */
export function shortenId(id: string): string {
    if (id.length < 9) {
        return id
    }

    return id.slice(0, 3) + "..." + id.slice(-3)
}