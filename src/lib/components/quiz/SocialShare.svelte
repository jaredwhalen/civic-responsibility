<script>
	import { X, Facebook, Linkedin, Copy } from '@lucide/svelte';
	import { browser } from '$app/environment';

	let { results } = $props();

	// Generate the social media text based on results
	const socialText = $derived.by(() => {
		let text = 'My civic profile is closest to ';

		// Add age prediction
		if (results.predictions.age_binary) {
			const age = results.predictions.age_binary.predicted[0];
			text += age === 'old' ? 'an older' : 'a younger';
		}

		text += ' ';

		// Add urban/rural prediction
		if (results.predictions.urban_binary) {
			const urban = results.predictions.urban_binary.predicted[0];
			text += urban.toLowerCase();
		}

		text += ' ';

		// Add ideology prediction
		if (results.predictions.ideology_tri) {
			const ideology = results.predictions.ideology_tri.predicted[0];
			text += ideology.toLowerCase();
		}

		text += ". What's your civic profile? Find out at";

		return text;
	});

	// Get current page URL for sharing
	const shareUrl = 'https://beaconproject.us/';

	// Social media sharing functions
	const shareOnX = () => {
		if (!browser) return;
		const url = `https://x.com/intent/post?text=${encodeURIComponent(socialText + ' ' + shareUrl)}`;
		console.log(url);
		window.open(url, '_blank', 'width=550,height=420');
	};

	const shareOnFacebook = () => {
		if (!browser) return;
		const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`;
		window.open(url, '_blank', 'width=550,height=420');
	};

	const shareOnLinkedIn = () => {
		if (!browser) return;
		const url = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(shareUrl)}`;
		window.open(url, '_blank', 'width=550,height=420');
	};

	const copyToClipboard = async () => {
		if (!browser) return;
		try {
			await navigator.clipboard.writeText(socialText + ' ' + shareUrl);
			// You could add a toast notification here if desired
			console.log('Text copied to clipboard');
		} catch (err) {
			console.error('Failed to copy text: ', err);
		}
	};

	const iconSize = 24;
</script>

<div class="social-share-container">
	<h4 class="share-title">Share your Results</h4>
	<div class="social-icons">
		<button class="social-button x" onclick={shareOnX} aria-label="Share on X" title="Share on X">
			<svg
				width="20"
				height="20"
				viewBox="0 0 1200 1227"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<path
					d="M714.163 519.284L1160.89 0H1055.03L667.137 450.887L357.328 0H0L468.492 681.821L0 1226.37H105.866L515.491 750.218L842.672 1226.37H1200L714.137 519.284H714.163ZM569.165 687.828L521.697 619.934L144.011 79.6944H306.615L611.412 515.685L658.88 583.579L1055.08 1150.3H892.476L569.165 687.854V687.828Z"
					fill="white"
				/>
			</svg>
		</button>

		<button
			class="social-button facebook"
			onclick={shareOnFacebook}
			aria-label="Share on Facebook"
			title="Share on Facebook"
		>
			<Facebook size={iconSize} />
		</button>

		<button
			class="social-button linkedin"
			onclick={shareOnLinkedIn}
			aria-label="Share on LinkedIn"
			title="Share on LinkedIn"
		>
			<Linkedin size={iconSize} />
		</button>

		<button
			class="social-button copy"
			onclick={copyToClipboard}
			aria-label="Copy to clipboard"
			title="Copy to clipboard"
		>
			<Copy size={iconSize} />
		</button>
	</div>
</div>

<style lang="scss">
	.social-share-container {
		text-align: center;
		margin-top: 2rem;
		padding: 1.5rem;
		background-color: #f8f9fa;
		border-radius: 12px;
	}

	.share-title {
		font-size: 1.2rem;
		font-weight: 600;
		color: #333;
		margin: 0 0 1rem 0;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.social-icons {
		display: flex;
		justify-content: center;
		gap: 1rem;
		margin-bottom: 0.75rem;
	}

	.social-button {
		display: flex;
		align-items: center;
		justify-content: center;
		width: 50px;
		height: 50px;
		border: none;
		border-radius: 50%;
		cursor: pointer;
		transition: all 0.2s ease;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

		&:hover {
			transform: translateY(-2px);
			box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
		}

		&:active {
			transform: translateY(0);
		}

		&.x {
			background-color: #000;
			color: white;

			&:hover {
				background-color: #0d8bd9;
			}
		}

		&.facebook {
			background-color: #1877f2;
			color: white;

			&:hover {
				background-color: #166fe5;
			}
		}

		&.linkedin {
			background-color: #0077b5;
			color: white;

			&:hover {
				background-color: #005885;
			}
		}

		&.copy {
			background-color: #6c757d;
			color: white;

			&:hover {
				background-color: #545b62;
			}
		}
	}

	.share-note {
		font-size: 0.9rem;
		color: #666;
		margin: 0;
		font-style: italic;
	}

	@media (max-width: 480px) {
		.social-icons {
			gap: 0.75rem;
		}

		.social-button {
			width: 45px;
			height: 45px;
		}

		.share-title {
			font-size: 1.1rem;
		}
	}
</style>
