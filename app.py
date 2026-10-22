import streamlit as st

st.set_page_config(
    page_title="Hyundai Automotive Intelligence",
    page_icon="🚗",
    layout="wide"
)

st.title("Hyundai Automotive Supply Chain, Manufacturing & Export Intelligence")

manufacturing = "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Manufacturing%20%26%20Quality.png"
inventory = "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Inventory%20%26%20logistics.png"
exports = "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Export%20%26%20customs.png"
imports = "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Import.png"

t1, t2, t3, t4 = st.tabs([
    "Manufacturing & Quality",
    "Inventory & Logistics",
    "Export & Customs",
    "Import"
])

with t1:
    st.image(manufacturing, use_container_width=True)

with t2:
    st.image(inventory, use_container_width=True)

with t3:
    st.image(exports, use_container_width=True)

with t4:
    st.image(imports, use_container_width=True)
