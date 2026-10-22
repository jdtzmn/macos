# Explaining feedback: calibration examples

All scenarios and comments below are fictional. Their facts are supplied as assumptions so the reasoning can be evaluated without a repository or private context. They demonstrate explanation depth, not a required format or a universal product recommendation.

## A product decision: saving edits to a shared recipe

### Scenario

An imaginary recipe-sharing application has a proposed editor that saves every change directly to the recipe other people can read. The proposal removes the explicit Save button. Assume the application does not currently promise live collaborative editing, and the team has not established whether its users usually make quick corrections or experiment with larger changes.

### Weak feedback

> Can we keep an explicit Save button instead of updating the shared recipe automatically? Users should decide when their changes are ready. We could save a private draft in the background and publish it when they click Save. Can the product owner confirm that behavior before we merge this?

### Why it fails

- It prescribes a replacement without explaining what automatic saving improves or what retaining a button costs.
- “Users should decide” asserts a preference but does not explain a concrete consequence of the proposed behavior.
- It introduces private drafts as though they were free, without considering the extra state or the possibility of forgotten unpublished edits.
- Asking an owner to decide does not supply the reasoning that would help them make that decision.

The problem is missing reasoning, not a lack of polished wording or a need for more implementation detail.

### Stronger feedback

> Saving automatically removes a step and protects people who close the editor without remembering to save. My concern is that this proposal also makes every unfinished edit visible to other readers. If someone changes a recipe from four servings to eight, the ingredient quantities may disagree while they work through the list, and another person could start cooking from that intermediate version.
>
> An explicit Save button gives the author a clear point at which the whole revision becomes visible, but simply restoring the button would bring back the risk of losing work. Saving a private draft automatically and applying it to the shared recipe only on Save would address both concerns. That does add a distinction between draft and shared content, and someone could leave a completed revision unpublished. We would need a clear indication that their edits are saved privately but not yet shared.
>
> I would prefer that extra state if people use the editor to work through substantial revisions, because those revisions should be readable as a whole. If most edits are small corrections, or people expect to collaborate live, making every change visible immediately may be the better tradeoff; a separate publishing step could get in their way. We haven't established which use case we're optimizing for, so I wouldn't treat an explicit Save button as universally better.
>
> Can we confirm the intended editing workflow before removing the button? For a draft-and-publish workflow, I'd keep the explicit action and make draft recovery part of the change. For live collaboration, I'd keep automatic updates and make it apparent when someone is editing. Those are different promises to readers, even if both implementations save every keystroke.

### What makes it work

- The opening identifies a real benefit of the proposal: less manual work and protection against forgotten saves. It does not add generic praise.
- The recipe example traces a concrete consequence: a revision reaches readers before its related changes are complete. “User control” alone would not explain that risk.
- The alternative is evaluated rather than merely requested. Private drafts preserve unfinished work, but add a publishing distinction and a risk of forgotten unpublished changes.
- The recommendation depends on the intended task. Substantial revisions and live collaboration justify different behavior; the comment states what would change its recommendation.
- The closing asks for a specific decision before choosing an implementation. It does not ask for ownership as a substitute for analysis.

The supplied scenario makes these concerns plausible, not measured. In a real review, verify the save behavior and distinguish observed user needs from hypotheses. This length is earned by a product choice with competing goals; do not reproduce four paragraphs for every finding.

## A deterministic bug: short feedback is enough

Assume a fictional thumbnail tool loops over a list with `index < images.length - 1`, and its requirement is to process every image.

Weak:

> Please fix the loop bound. We should process every image.

Better:

> This loop stops before the last image. With three images it processes only the first two; with one image it produces no thumbnail at all. Please include the final index so every selected image is processed.

The short version is sufficient because the failure follows directly from the stated inputs. It does not need a manufactured benefit of the broken bound, a balanced debate, or an essay about iteration. In a real review, verify the requirement and loop behavior before making the claim.

## An architecture recommendation after an investigation

### Scenario

Assume a fictional shop stores prices as integer cents but promises decimal currency amounts in its public catalog API. Two catalog endpoints currently divide by 100 themselves. An investigation confirms that a third endpoint returns stored cents unchanged, and that every catalog response already passes through a shared response serializer. Internal batch exports deliberately use cents and do not use that serializer. No customer impact has been measured.

### Weak feedback

> We already have a boundary. Normalize the representation there rather than adding more opt-in conversion sites. This shouldn't wait for the money-model redesign.

The recommendation may be sound, but it assumes the reader knows the representation, the boundary, and what goes wrong. Naming an architectural pattern does not explain the problem.

### Stronger feedback

> Today each catalog endpoint has to remember to convert stored cents into the currency amount promised by the API. Keeping that decision local lets each endpoint choose its own output units, but these endpoints all promise the same ones, and the third misses the conversion: a stored price of 1,299 cents is returned as 1,299 rather than 12.99. A client following the documented contract would interpret that as a price one hundred times too high. We haven't established whether any customer has encountered this.
>
> Every catalog response already passes through the shared response serializer—the function that turns an internal record into the public API shape. Putting the conversion there would make it part of producing a catalog response, rather than something each endpoint must remember to do. That couples the serializer to the catalog's price contract, so internal exports that intentionally use cents must stay on their separate path. I think that is the right boundary here: these endpoints all promise the same units, and the export path already has a different contract.
>
> I'd move the conversion into that existing serializer and remove the endpoint-specific copies now, rather than waiting for a larger money-model redesign. Can we make that change and check that all three endpoints return the documented units? If another public endpoint intentionally needs cents, it should have an explicit separate contract rather than inherit this conversion accidentally.

### A shorter version that keeps the explanation

> Each catalog endpoint currently has to remember to convert cents into the API's currency amount. The third misses that step, so 1,299 cents becomes 1,299 instead of 12.99. Can we convert in the response serializer that every catalog response already uses, and remove the per-endpoint copies? This makes that serializer enforce one price representation rather than leaving the choice to each endpoint; that is appropriate because they all promise the same units. Keep internal exports separate because they intentionally use cents. We can enforce the existing contract without waiting for the larger redesign.

Both versions pass the comprehension gate: current behavior, concrete failure, mechanism, and tradeoff are present. The shorter version removes detail, not the reason for the request. In real feedback, establish the shared path's coverage before recommending it; a plausible central-sounding function name is not evidence.

## Routing examples

Load `explain-feedback` for:

- “Write this as a single PR review comment.”
- “What feedback would you give on this UX?”
- “I think this abstraction is too complicated. How should I explain that to the author?”
- “Why is this a problem, and what would you recommend instead?”
- “Turn these review findings into feedback I can send.”
- “Rewrite this comment; it asks for a change but doesn't explain the tradeoff.”
- “Given what you found, should we wait for the redesign or change this now?”
- “That makes sense. Turn your recommendation into a comment the author can understand without this conversation.”
- “Shorten that to one comment, but keep why the change matters.”
- “This is still telling them what to do. Explain why the current approach is a problem.”
- A general review task when delivering human-facing findings, without replacing the review's evidence-gathering workflow.

Do not load solely for:

- “Summarize the changed files.”
- “What is the current CI status?”
- “Implement this agreed change.”
- “Explain how this function works,” without critique or a recommendation.
- Personal performance feedback; it needs a different interpersonal workflow.

Explicitly naming `/skill:explain-feedback` always requests this workflow. Examples do not authorize posting comments or taking implementation actions.
