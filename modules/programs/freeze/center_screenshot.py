import os
import sys

from wand.image import Image


def center_code_screenshot(input_path, output_path):
    if not os.path.exists(input_path):
        print(f"Error: File '{input_path}' not found.")
        sys.exit(1)

    with Image(filename=input_path) as img:
        with img.clone() as content:
            content.trim(fuzz=0.1 * img.quantum_range)
            _, _, offset_x, offset_y = content.page
            trim_w, trim_h = content.width, content.height

        orig_w, orig_h = img.width, img.height

        margin_left = offset_x
        margin_top = offset_y
        margin_right = orig_w - (offset_x + trim_w)
        margin_bottom = orig_h - (offset_y + trim_h)

        min_margin = min(margin_left, margin_top, margin_right, margin_bottom)

        if min_margin < 0:
            min_margin = 0

        new_left = offset_x - min_margin
        new_top = offset_y - min_margin
        new_width = trim_w + (2 * min_margin)
        new_height = trim_h + (2 * min_margin)

        img.crop(
            left=int(new_left),
            top=int(new_top),
            width=int(new_width),
            height=int(new_height),
        )

        img.save(filename=output_path)
        print(f"Balanced successfully -> {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: center-screenshot <input_image> <output_image>")
        sys.argv = ["", "input.png", "output.png"]
        sys.exit(1)

    center_code_screenshot(sys.argv[1], sys.argv[2])
