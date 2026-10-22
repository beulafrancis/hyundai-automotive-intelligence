
import streamlit as st

st.set_page_config(
    page_title="Hyundai Automotive Intelligence",
    page_icon="🚗",
    layout="wide"
)

st.title("🚗 Hyundai Automotive Supply Chain, Manufacturing & Export Intelligence")

st.write(
    "Explore manufacturing, quality, inventory, logistics, "
    "vehicle exports and customs operations."
)

st.caption("Data Analytics Portfolio | PostgreSQL · SQL · Power BI")

st.divider()

st.subheader("Automotive Dashboard")

tab1, tab2, tab3, tab4 = st.tabs([
    "Manufacturing & Quality",
    "Inventory & Logistics",
    "Export & Customs",
    "Import"
])

with tab1:
    st.image(
        "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Manufacturing%20%26%20Quality.png",
        use_container_width=True
    )

with tab2:
    st.image(
        "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Inventory%20%26%20logistics.png",
        use_container_width=True
    )

with tab3:
    st.image(
        "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Export%20%26%20customs.png",
        use_container_width=True
    )

with tab4:
    st.image(
        "https://raw.githubusercontent.com/beulafrancis/hyundai-automotive-intelligence/main/Import.png",
        use_container_width=True
    )

st.divider()

st.markdown(
    "[View project source code on GitHub](https://github.com/beulafrancis/hyundai-automotive-intelligence)"
)
