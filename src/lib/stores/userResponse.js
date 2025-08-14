import { writable } from 'svelte/store';

export const userResponse = writable({
    guess: 50,
});