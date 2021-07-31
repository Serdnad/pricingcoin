import type Session from "$lib/models/session"
import { Writable, writable } from "svelte/store"

// Note: stores are useful for sharing state across multiple components,
//  without having to pass data and callbacks around as props, or use
//  event dispatches.
/** The most recently selected session. */
export const selectedSession: Writable<Session> = writable(undefined)