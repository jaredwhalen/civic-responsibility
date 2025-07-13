import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
	plugins: [sveltekit()],
	css: {
		preprocessorOptions: {
			scss: {
				additionalData: `
					@import "${resolve('src/lib/styles/variables.scss')}";
					@import "${resolve('src/lib/styles/mixins.scss')}";
				`
			}
		}
	}
});
