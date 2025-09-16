<script>
    import PinSlide from './PinSlide.svelte';
    import { onMount } from 'svelte';
    
	const sectionHeight = "200vh";
	const totalHeight = `calc(4 * ${sectionHeight})`;

	const slides = [
		{
			text: "Slide 1",
			art: "Art 1"
		},
		{
			text: "Slide 2",
			art: "Art 2"
		}
	]


    let scrollProgress = $state({});
    let slideRefs = $state([]);
    let slideElements = $derived(slideRefs.map(ref => ref?.slideElement));


    onMount(() => {
        const updateScrollProgress = () => {
            const scrollY = window.scrollY;
            const windowHeight = window.innerHeight;
            
            slideElements.forEach((element, index) => {
                if (!element) return;
                
                const rect = element.getBoundingClientRect();
                const elementTop = rect.top + scrollY;
                const elementHeight = rect.height;
                
                // Each slide takes 100vh to scroll through
                // Slide starts when it enters viewport, ends when it leaves
                const slideStart = elementTop - windowHeight;
                const slideEnd = elementTop + elementHeight;
                
                let progress = 0;
                if (scrollY >= slideStart && scrollY <= slideEnd) {
                    progress = Math.max(0, Math.min(100, ((scrollY - slideStart) / (slideEnd - slideStart)) * 100));
                } else if (scrollY > slideEnd) {
                    progress = 100;
                }
                
                scrollProgress[index] = progress;
            });
        };
        
        window.addEventListener('scroll', updateScrollProgress);
        updateScrollProgress(); // Initial calculation
        
        return () => {
            window.removeEventListener('scroll', updateScrollProgress);
        };
    });
</script>

<div class="pin-scroller" style="--section-height: {sectionHeight}; --total-height: {totalHeight};">
    {#each slides as slide, i}
        <PinSlide 
            i={slide} 
            bind:this={slideRefs[i]}
            progress={scrollProgress[i] || 0}
        />
    {/each}
</div>

<style lang="scss">
	@import '../../styles/variables.scss';
	.pin-scroller {
		position: relative;
		width: 100%;
		height: var(--total-height);
	}
</style>
