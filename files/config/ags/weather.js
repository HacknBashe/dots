const WEATHER_CODES = {
  113: " ",
  116: " ",
  119: " ",
  122: " ",
  143: " ",
  176: " ",
  179: " ",
  182: " ",
  185: " ",
  200: " ",
  227: " ",
  230: " ",
  248: " ",
  260: " ",
  263: " ",
  266: " ",
  281: " ",
  284: " ",
  293: " ",
  296: " ",
  299: " ",
  302: " ",
  305: " ",
  308: " ",
  311: " ",
  314: " ",
  317: " ",
  320: " ",
  323: " ",
  326: " ",
  329: " ",
  332: " ",
  335: " ",
  338: " ",
  350: " ",
  353: " ",
  356: " ",
  359: " ",
  362: " ",
  365: " ",
  368: " ",
  371: " ",
  374: " ",
  377: " ",
  386: " ",
  389: " ",
  392: " ",
  395: " ",
};

const formatTime = (time) => time.replace("00", "").padStart(2, "0");

const formatTemp = (temp) => `${temp}°`.padEnd(3);

const formatChances = (hour) => {
  const chances = {
    chanceoffog: "Fog",
    chanceoffrost: "Frost",
    chanceofovercast: "Overcast",
    chanceofrain: "Rain",
    chanceofsnow: "Snow",
    chanceofsunshine: "Sunshine",
    chanceofthunder: "Thunder",
    chanceofwindy: "Wind",
  };

  let conditions = [];
  for (let event in chances) {
    if (parseInt(hour[event]) > 0) {
      conditions.push(`${chances[event]} ${hour[event]}%`);
    }
  }
  return conditions.join(", ");
};

export function Weather() {
  const self = Widget.Label({
    className: "weather",
  });

  Utils.interval(
    10000,
    () => {
      self.label = "󰼯";
      self.tooltip_markup = "Wttr.in fetch error.";
      Utils.fetch("https://wttr.in/Lancaster,NewYork?format=j1")
        .then((res) => res.text())
        .then((res) => {
          const weather = JSON.parse(res);
          const output = {};

          output["text"] =
            WEATHER_CODES[weather["current_condition"][0]["weatherCode"]] +
            " " +
            weather["current_condition"][0]["FeelsLikeF"] +
            "°";

          output["tooltip"] =
            `<b>${weather["current_condition"][0]["weatherDesc"][0]["value"]} ${weather["current_condition"][0]["temp_C"]}°</b>\n`;
          output["tooltip"] +=
            `Feels like: ${weather["current_condition"][0]["FeelsLikeF"]}°\n`;
          output["tooltip"] +=
            `Wind: ${weather["current_condition"][0]["windspeedKmph"]}Km/h\n`;
          output["tooltip"] +=
            `Humidity: ${weather["current_condition"][0]["humidity"]}%\n`;

          weather["weather"].forEach((day, i) => {
            output["tooltip"] += `\n<b>`;
            if (i === 0) {
              output["tooltip"] += "Today, ";
            } else if (i === 1) {
              output["tooltip"] += "Tomorrow, ";
            }
            output["tooltip"] += `${day["date"]}</b>\n`;
            output["tooltip"] += ` ${day["maxtempC"]}°  ${day["mintempC"]}° `;
            output["tooltip"] +=
              `  ${day["astronomy"][0]["sunrise"]}  ${day["astronomy"][0]["sunset"]}\n`;

            day["hourly"].forEach((hour) => {
              let currentHour = new Date().getHours();
              if (
                i === 0 &&
                parseInt(formatTime(hour["time"])) < currentHour - 2
              ) {
                return;
              }
              output["tooltip"] +=
                `${formatTime(hour["time"])} ${WEATHER_CODES[hour["weatherCode"]]} ${formatTemp(hour["FeelsLikeF"])} ${hour["weatherDesc"][0]["value"]}, ${formatChances(hour)}\n`;
            });
          });

          self.label = output["text"];
          self.tooltip_markup = output["tooltip"];
        })
        .catch(console.error);
    },
    self,
  );

  return self;
}
