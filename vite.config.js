import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { resolve } from 'path';
import dsv from '@rollup/plugin-dsv';

export default defineConfig({
	plugins: [sveltekit(), dsv()],
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
