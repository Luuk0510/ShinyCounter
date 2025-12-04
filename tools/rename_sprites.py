import pathlib
import re
import shutil

# Dry-run by default so you can preview changes safely.
DRY_RUN = False

# Root directory containing the current sprite files.
SRC_DIR = pathlib.Path("assets/pokemons")

# Expected current pattern:
# poke_capture_{dex4}_{form3}_{genderToken}_{formType}_..._{shinyFlag}.png
PATTERN = re.compile(
    r"poke_capture_(\d{4})_(\d{3})_((?:[mf]{1,2}[d]?|uk|fo|mo))_([ng])_.*?_([nr])\.png",
    re.IGNORECASE,
)


def map_gender(token: str) -> str:
    """Normalize gender token to m/f/mf."""
    token = token.lower()
    if token.startswith("md"):
        return "m"
    if token.startswith("fd"):
        return "f"
    if token.startswith("mo"):
        return "m"
    if token.startswith("fo"):
        return "f"
    if token.startswith("uk"):
        return "mf"
    return "mf"


def map_form(form: str, form_type: str) -> str | None:
    """
    Map form + type to our target form name.
    Returns None to skip unwanted variants.
    """
    form = form.lower()
    form_type = form_type.lower()
    if form_type == "g":
        return "gmax"
    if form == "000":
        return "base"
    # Treat other numbered forms as megas/alt forms
    return f"mega-{form}"


def build_new_name(dex: str, form_name: str, gender: str) -> str:
    # {dex4}_{form}_{region}_{variant}_{gender}_{shineFlag}.png
    # shineFlag: s = shiny, n = normal
    return f"{dex}_{form_name}_std_none_{gender}_{{shine}}.png"


def main() -> None:
    if not SRC_DIR.exists():
        print(f"Source directory missing: {SRC_DIR}")
        return

    for file in sorted(SRC_DIR.glob("*.png")):
        match = PATTERN.fullmatch(file.name)
        if not match:
            print(f"skip (no match): {file.name}")
            continue

        dex, form, gender_token, form_type, shiny_flag = match.groups()

        form_name = map_form(form, form_type)
        if form_name is None:
            print(f"skip (filtered form): {file.name}")
            continue

        gender = map_gender(gender_token)
        shine = "s" if shiny_flag.lower() == "r" else "n"
        new_name = build_new_name(dex, form_name, gender).format(shine=shine)
        new_path = file.with_name(new_name)

        if DRY_RUN:
            print(f"{file.name} -> {new_name}")
        else:
            if new_path.exists():
                print(f"target exists, skipping: {new_name}")
                continue
            shutil.move(str(file), str(new_path))
            print(f"renamed: {file.name} -> {new_name}")


if __name__ == "__main__":
    main()
