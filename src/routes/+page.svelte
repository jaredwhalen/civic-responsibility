<script>
import Scrolly from '$lib/components/scrolly/Scrolly.svelte';
import Slide from '$lib/components/scrolly/Slide.svelte';
import Hero from '$lib/components/Hero.svelte';
import Footer from '$lib/components/Footer.svelte';
import copy from '$lib/data/copy.json';

console.log(copy);

function scrollToScrolly() {
	window.scrollTo({top: window.innerHeight, behavior: 'smooth'});
}
</script>

<svelte:head>
	<title>{copy.meta.title}</title>
</svelte:head>


<!-- Header: Hamburger + Logos -->
<header class="main-header">
	<div class="header-left">
		<button class="hamburger" aria-label="Open menu">
			<span></span><span></span><span></span>
		</button>
	</div>
	<div class="header-right">
		<div class="logo logo-mic">More in Common</div>
		<div class="logo logo-beacon">BEACON PROJECT</div>
	</div>
</header>

<Hero
	videoSrc={copy.content.hero.video || '/videos/web-bg.mp4'}
	poster={copy.content.hero.poster || '/videos/placeholder.jpg'}
	heroText={copy.content.hero.text}
	onScrollClick={scrollToScrolly}
/>

<!-- Scrolly Slides -->
<Scrolly slideCount={5}>
	<Slide className="slide-1">
		<div class="slide-col slide-col-text" style="text-align:left;max-width:400px;margin-right:2rem;">
			<p class="slide-lead">Our country is increasingly polarized.</p>
			<p class="slide-body">
				In times of deep division, it is important to remember the values and principles that bind
				us together—those things we all share as Americans.
			</p>
		</div>
		<div class="slide-col slide-col-img">
			<div class="chart-placeholder">
				<strong>Political Polarization of the American Public, 1994-2014</strong>
				<div class="chart-img">[Chart Placeholder]</div>
				<small>Source: Pew Research Center</small>
			</div>
		</div>
	</Slide>
	{#each Array(4) as _, i}
		<Slide>
			<h2>Slide {i + 2}</h2>
			<p>
				Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque euismod, nisi eu
				consectetur.
			</p>
		</Slide>
	{/each}
</Scrolly>

<Footer />

<style lang="scss">
body {
	background: #222;
}

.main-header {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: $spacing-md $spacing-lg;
	z-index: 2000;
	background: transparent;
	pointer-events: none;

	.header-left,
	.header-right {
		pointer-events: auto;
	}
	.header-left {
		display: flex;
		align-items: center;
	}
	.hamburger {
		background: none;
		border: none;
		padding: 0;
		width: 36px;
		height: 36px;
		display: flex;
		flex-direction: column;
		justify-content: center;
		gap: 6px;
		cursor: pointer;
		span {
			display: block;
			height: 4px;
			width: 100%;
			background: #fff;
			border-radius: 2px;
		}
	}
	.header-right {
		display: flex;
		gap: $spacing-lg;
		.logo {
			color: #fff;
			font-weight: 700;
			font-size: 1.1rem;
			text-shadow: 0 1px 4px rgba(0, 0, 0, 0.4);
			&.logo-mic {
				letter-spacing: 0.02em;
			}
			&.logo-beacon {
				font-family: serif;
				letter-spacing: 0.08em;
			}
		}
	}
}

/* Slide-specific styles for two-column layout */
.slide-1 {
	display: flex;
	gap: $spacing-xl;
	max-width: 1200px;
	margin: 0 auto;
	width: 100%;
	@media (max-width: 900px) {
		flex-direction: column;
		gap: $spacing-lg;
	}
	.slide-col {
		flex: 1;
		&.slide-col-text {
			padding-right: $spacing-xl;
			@media (max-width: 900px) {
				padding-right: 0;
			}
			.slide-lead {
				font-size: 1.2rem;
				font-weight: 500;
				margin-bottom: $spacing-lg;
			}
			.slide-body {
				font-size: 1.1rem;
				color: $text-light;
			}
		}
		&.slide-col-img {
			.chart-placeholder {
				background: #fff;
				border-radius: $border-radius-md;
				box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
				padding: $spacing-lg;
				text-align: center;
				.chart-img {
					height: 180px;
					background: linear-gradient(90deg, #b6e36c 0%, #e3e3e3 100%);
					border-radius: $border-radius-sm;
					margin: $spacing-md 0;
					display: flex;
					align-items: flex-end;
					justify-content: center;
					color: #333;
					font-size: 1.2rem;
				}
			}
		}
	}
}
</style>
